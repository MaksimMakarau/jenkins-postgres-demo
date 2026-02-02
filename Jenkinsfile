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
        stage('Checkout SCM') {
            // Этот этап нужен, чтобы Jenkins скачал папку db/ с GitHub
            steps {
                checkout scm
            }
        }
        /*stage('Check Connectivity') {
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
        }*/
         stage('Liquibase Migration') {
            steps {
                withCredentials([string(credentialsId: 'postgres-db-pass', variable: 'DB_PASSWORD')]) {
                    script {
                        echo "Запускаем миграцию базы данных через Liquibase..."
                        
                        // Мы монтируем текущую папку workspace (%WORKSPACE%) внутрь контейнера,
                        // чтобы Liquibase увидел наш файл db/changelog.sql
                        bat """
                            docker run --rm ^
                            -v "%WORKSPACE%/db":/liquibase/changelog ^
                            liquibase/liquibase ^
                            --url="jdbc:postgresql://%DB_HOST%:%DB_PORT%/%DB_NAME%" ^
                            --changeLogFile=changelog.sql ^
                            --username=postgres ^
                            --password=%DB_PASSWORD% ^
                            update
                        """
                    }
                }
            }
        }
        /*stage('Create Table on VM') {
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
        }*/
        stage('Verify Data') {
            steps {
                withCredentials([string(credentialsId: 'postgres-db-pass', variable: 'DB_PASSWORD')]) {
                    script {
                        echo "=== Автоматическая проверка данных ==="
                        // Мы делаем SELECT. Если подключение пройдет успешно, мы увидим данные в логе.
                        // Если что-то сломалось, команда вернет код ошибки, и пайплайн покраснеет.
                        bat """
                            docker run --rm ^
                            -e PGPASSWORD=%DB_PASSWORD% ^
                            postgres:alpine ^
                            psql -h %DB_HOST% -U %DB_USER% -d postgres -c "SELECT * FROM users;"
                        """
                    }
                }
            }
        }
    }
}
