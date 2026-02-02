pipeline {
    agent any 

    environment {
        // Настройки для Windows + Docker Desktop
        DOCKER_HOST = 'tcp://127.0.0.1:2375'
        CONTAINER_NAME = 'jenkins-postgres-db'
    }

    stages {
        stage('Start Database') {
            steps {
                // Используем сохраненный секрет
                withCredentials([string(credentialsId: 'postgres-db-pass', variable: 'DB_PASSWORD')]) {
                    script {
                        echo 'Запускаем PostgreSQL из GitHub-пайплайна...'
                        // Очистка старого контейнера
                        bat "docker rm -f ${CONTAINER_NAME} > NUL 2>&1 || exit 0"
                        
                        // Запуск нового
                        bat "docker run -d --name ${CONTAINER_NAME} -e POSTGRES_PASSWORD=%DB_PASSWORD% postgres:alpine"
                    }
                }
            }
        }

        stage('Wait for DB') {
            steps {
                echo 'Ждем инициализации базы...'
                sleep time: 5, unit: 'SECONDS'
            }
        }

        stage('Execute SQL') {
            steps {
                withCredentials([string(credentialsId: 'postgres-db-pass', variable: 'DB_PASSWORD')]) {
                    script {
                        echo 'Проверяем версию базы...'
                        bat "docker exec ${CONTAINER_NAME} psql -U postgres -c \"SELECT version();\""
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                echo 'Финальная очистка...'
                bat "docker rm -f ${CONTAINER_NAME} > NUL 2>&1 || exit 0"
            }
        }
    }
}
