## Створення нового тому
Для створення нового тому використовуємо таку команду, 
де mssql-storage - назва тому
```sh
docker volume create mssql-storage 
```

## Запуск контейнеру з підключенням до тому
 - -e "MSSQL_SA_PASSWORD=YourStrongPassword1!" - встановлення паролю
 - -p 1433:1433 - вибір порту
 - -v mssql-storage:/var/opt/mssql - підключення тому
 - --name mssql-study - присвоєння імені контейнеру 
 - mcr.microsoft.com/mssql/server:2022-latest - образ який буде використано
```sh
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=YourStrongPassword1!" -p 1433:1433 -v mssql-storage:/var/opt/mssql --name mssql-study -d mcr.microsoft.com/mssql/server:2022-latest
```
## Перевірка підключення контейнеру до тому
```sh
docker inspect --format "{{json .Mounts}}" mssql-study
```

## Зупинка контейнеру
```sh
docker stop mssql-study
```

## Видалення контейнеру
```sh
docker rm mssql-study 
```


