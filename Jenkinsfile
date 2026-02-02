pipeline {
    agent any 

    environment {
        // Укажи IP адрес твоей VirtualBox машины
        DB_HOST = 'host.docker.internal' 
        DB_PORT = '5432'
        DB_USER = 'postgres' // Или имя твоего пользователя в Debian
        
        // Настройка Docker клиента (как и раньше)
        DOCKER_HOST = 'tcp://127.0.0.1:2375'
    }

    stages {
        stage('Check Connectivity') {
            steps {
                // Используем credentials, которые мы создали ранее
                withCredentials([string(credentialsId: 'postgres-db-pass', variable: 'DB_PASSWORD')]) {
                    script {
                        echo "Подключаемся к удаленной базе на ${DB_HOST}..."
                        
                        // Мы запускаем контейнер postgres:alpine, но используем его только как утилиту psql.
                        // Команда psql -h IP_ADDRESS подключается к удаленному серверу.
                        bat """
                            docker run --rm ^
                            -e PGPASSWORD=%DB_PASSWORD% ^
                            postgres:alpine ^
                            psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d postgres -c "SELECT inet_server_addr(), version();"
                        """
                    }
                }
            }
        }
        
        stage('Create Table on VM') {
            steps {
                withCredentials([string(credentialsId: 'postgres-db-pass', variable: 'DB_PASSWORD')]) {
                    script {
                        echo "Создаем тестовую таблицу на Debian..."
                        bat """
                            docker run --rm ^
                            -e PGPASSWORD=%DB_PASSWORD% ^
                            postgres:alpine ^
                            psql -h %DB_HOST% -U %DB_USER% -d postgres -c "CREATE TABLE IF NOT EXISTS jenkins_test (id serial PRIMARY KEY, info text); INSERT INTO jenkins_test (info) VALUES ('Hello from Windows');"
                        """
                    }
                }
            }
        }
    }
}
