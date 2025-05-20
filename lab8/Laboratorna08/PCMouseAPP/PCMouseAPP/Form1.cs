using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Windows.Forms;

namespace PCMouseAPP
{
    public partial class Form1 : Form
    {
        private string connectionString = "Data Source=DESKTOP-C5TOBO7;Initial Catalog=PCMouse;Integrated Security=True";

        public Form1()
        {
            InitializeComponent();
        }

        Dictionary<string, List<string>> tableColumns = new Dictionary<string, List<string>>
        {
            { "Customer", new List<string> { "CustomerId", "FirstName", "LastName", "Email", "PhoneNumber", "ShippingAddress", "BonusAccountNumber" } },
            { "Supplier", new List<string> { "SupplierId", "Name", "Address", "ContactNumber", "Email" } },
            { "ComputerMouse", new List<string> { "ProductId", "ModelName", "Brand", "Type", "ButtonCount", "Size", "Price", "StockQuantity","Color", "SupplierId" } },
            { "OrderTable", new List<string> { "OrderId", "CustomerId", "OrderDate", "TotalAmount" } },
            { "OrderDetails", new List<string> { "OrderDetailsId", "ProductId", "OrderId", "ProductQuantity", "ItemAmount" } }
        };

        Dictionary<string, string> tablePrimaryKeys = new Dictionary<string, string>
        {
            { "Customer", "CustomerId" },
            { "Supplier", "SupplierId" },
            { "ComputerMouse", "ProductId" },
            { "OrderTable", "OrderId" },
            { "OrderDetails", "OrderDetailsId" }
        };

        private void LoadCurrentTable()
        {
            string tableName = tableNames[currentTableIndex];

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                try
                {
                    conn.Open();
                    SqlDataAdapter adapter = new SqlDataAdapter($"SELECT * FROM {tableName}", conn);
                    DataTable dt = new DataTable();
                    adapter.Fill(dt);
                    dataGridView1.DataSource = dt;
                    this.Text = $"Відображається таблиця: {tableName}";
                    txtPageNumber.Text = (currentTableIndex + 1).ToString();
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Помилка при завантаженні: " + ex.Message);
                }
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            dataTable = new DataTable();
            LoadCurrentTable(); 
        }
        private void BtnFirst_Click(object sender, EventArgs e)
        {
            currentTableIndex = 0;
            LoadCurrentTable();
        }
        private void BtnLast_Click(object sender, EventArgs e)
        {
            currentTableIndex = 4;
            LoadCurrentTable();
        }
        private void BtnPrev_Click(object sender, EventArgs e)
        {
            if (currentTableIndex > 0)
            {
                currentTableIndex--;
                LoadCurrentTable();
            }
        }

        private void BtnNext_Click(object sender, EventArgs e)
        {
            if (currentTableIndex < tableNames.Count - 1)
            {
                currentTableIndex++;
                LoadCurrentTable();
            }
        }

        private void BtnLoad_Click(object sender, EventArgs e)
        {
            LoadCurrentTable();
        }
        private void BtnEdit_Click(object sender, EventArgs e)
        {
            if (dataGridView1.CurrentRow == null)
            {
                MessageBox.Show("Оберіть рядок для редагування.");
                return;
            }

            string tableName = tableNames[currentTableIndex];
            List<string> columns = tableColumns[tableName];
            string primaryKey = tablePrimaryKeys[tableName];
            object keyValue = dataGridView1.CurrentRow.Cells[primaryKey].Value;

            string updateQuery = $"UPDATE {tableName} SET " +
                string.Join(", ", columns.Where(c => c != primaryKey).Select(c => $"{c} = @{c}")) +
                $" WHERE {primaryKey} = @{primaryKey}";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
            {
                try
                {
                    conn.Open();

                    DataTable schemaTable = conn.GetSchema("Columns", new[] { null, null, tableName, null });
                    Dictionary<string, string> columnTypes = new Dictionary<string, string>();
                    foreach (DataRow row in schemaTable.Rows)
                    {
                        columnTypes.Add(row["COLUMN_NAME"].ToString(), row["DATA_TYPE"].ToString());
                    }

                    foreach (var col in columns)
                    {
                        object oldValue = dataGridView1.CurrentRow.Cells[col].Value;
                        object newValue = PromptForValue(col, oldValue);

                        if (newValue != null && columnTypes.ContainsKey(col))
                        {
                            string dataType = columnTypes[col];
                            SqlParameter param = new SqlParameter("@" + col, SqlDbType.NVarChar);

                            switch (dataType.ToLower())
                            {
                                case "int":
                                    int intValue;
                                    if (int.TryParse(newValue.ToString(), out intValue))
                                        param = new SqlParameter("@" + col, SqlDbType.Int) { Value = intValue };
                                    else
                                        throw new Exception($"Значення для {col} має бути цілим числом.");
                                    break;
                                case "decimal":
                                case "numeric":
                                case "money":
                                    decimal decValue;
                                    if (decimal.TryParse(newValue.ToString(), out decValue))
                                        param = new SqlParameter("@" + col, SqlDbType.Decimal) { Value = decValue };
                                    else
                                        throw new Exception($"Значення для {col} має бути числом з крапкою.");
                                    break;
                                case "datetime":
                                case "date":
                                    DateTime dateValue;
                                    if (DateTime.TryParse(newValue.ToString(), out dateValue))
                                        param = new SqlParameter("@" + col, SqlDbType.DateTime) { Value = dateValue };
                                    else
                                        throw new Exception($"Значення для {col} має бути датою у форматі ДД.ММ.РРРР.");
                                    break;
                                default:
                                    param = new SqlParameter("@" + col, SqlDbType.NVarChar) { Value = newValue };
                                    break;
                            }

                            cmd.Parameters.Add(param);
                        }
                        else
                        {
                            cmd.Parameters.AddWithValue("@" + col, newValue ?? DBNull.Value);
                        }
                    }

                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Дані успішно оновлено.");
                    LoadCurrentTable();
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Помилка при редагуванні: " + ex.Message);
                }
            }
        }
        private object PromptForValue(string columnName, object defaultValue = null)
        {
            Form inputForm = new Form();
            inputForm.Width = 300;
            inputForm.Height = 150;
            inputForm.FormBorderStyle = FormBorderStyle.FixedDialog;
            inputForm.Text = $"Введення значення для {columnName}";
            inputForm.StartPosition = FormStartPosition.CenterScreen;
            inputForm.MaximizeBox = false;
            inputForm.MinimizeBox = false;

            Label label = new Label();
            label.Text = $"Введіть значення для {columnName}:";
            label.Left = 10;
            label.Top = 20;
            label.Width = 265;
            inputForm.Controls.Add(label);

            TextBox textBox = new TextBox();
            textBox.Left = 10;
            textBox.Top = 50;
            textBox.Width = 265;
            if (defaultValue != null && defaultValue != DBNull.Value)
            {
                textBox.Text = defaultValue.ToString();
            }
            inputForm.Controls.Add(textBox);

            Button okButton = new Button();
            okButton.Text = "OK";
            okButton.Left = 120;
            okButton.Top = 80;
            okButton.Width = 60;
            okButton.DialogResult = DialogResult.OK;
            inputForm.Controls.Add(okButton);

            inputForm.AcceptButton = okButton;

            if (inputForm.ShowDialog() == DialogResult.OK)
            {
                return string.IsNullOrWhiteSpace(textBox.Text) ? null : textBox.Text;
            }
            else
            {
                return defaultValue;
            }
        }
        private void BtnAdd_Click(object sender, EventArgs e)
        {
            string tableName = tableNames[currentTableIndex];
            List<string> columns = tableColumns[tableName];
            List<string> parameters = columns.Select(c => "@" + c).ToList();

            string insertQuery = $"INSERT INTO {tableName} ({string.Join(", ", columns)}) VALUES ({string.Join(", ", parameters)})";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
            {
                foreach (var col in columns)
                {
                    object newValue = PromptForValue(col);
                    cmd.Parameters.AddWithValue("@" + col, newValue ?? DBNull.Value);
                }

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Запис успішно додано.");
                    LoadCurrentTable();
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Помилка при додаванні: " + ex.Message);
                }
            }
        }

        private void BtnDelete_Click(object sender, EventArgs e)
        {
            if (dataGridView1.CurrentRow == null)
            {
                MessageBox.Show("Оберіть рядок для видалення.");
                return;
            }

            DialogResult result = MessageBox.Show("Ви впевнені, що хочете видалити цей запис?",
                                                "Підтвердження видалення",
                                                MessageBoxButtons.YesNo,
                                                MessageBoxIcon.Warning);

            if (result != DialogResult.Yes)
                return;

            string tableName = tableNames[currentTableIndex];
            string primaryKey = tablePrimaryKeys[tableName];
            object keyValue = dataGridView1.CurrentRow.Cells[primaryKey].Value;

            string deleteQuery = $"DELETE FROM {tableName} WHERE {primaryKey} = @{primaryKey}";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
            {
                cmd.Parameters.AddWithValue("@" + primaryKey, keyValue);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Запис успішно видалено.");
                    LoadCurrentTable();
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Помилка при видаленні: " + ex.Message);
                }
            }
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }
    }
}