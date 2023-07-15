def VERSION

pipeline {
    agent any
    tools {
        maven 'Maven'
    }
    environment {
        ECR_REPO = "${ECR_SERVER}/spring-boot-app"
        ECR_SERVER = '874503558975.dkr.ecr.us-east-1.amazonaws.com'
        appName = 'springbootapp'
    }

    stages {
        stage('increment version') {
            steps {
                script {
                    sh "mvn build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} versions:commit"
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    VERSION = matcher[0][1]
                }
            }
        }

        stage('build jar') {
            steps {
                script {
                    sh 'mvn clean install'
                }
            }
        }

        stage('test') {
            steps {
                script {
                    sh 'mvn test'
                }
            }
        }

        stage('Build image') {
            steps {
                script {
                    def IMAGE = "${VERSION}-${BUILD_NUMBER}"
                    withCredentials([usernamePassword(credentialsId:'springbootapp-ecr-credentials', usernameVariable:'USER', passwordVariable:'PASS')]) {
                        sh "echo $PASS | docker login -u $USER --password-stdin ${ECR_SERVER}"
                        sh "docker build . -t ${ECR_REPO}:${IMAGE}"
                        sh "docker push ${ECR_REPO}:${IMAGE}"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def IMAGE = "${VERSION}-${BUILD_NUMBER}"
                    withKubeConfig(
                        caCertificate: '<CA_CERTIFICATE>',
                        clusterName: '<CLUSTER_NAME>',
                        contextName: '<CONTEXT_NAME>',
                        credentialsId: 'springboot-K8S',
                        namespace: '<NAMESPACE>',
                        restrictKubeConfigAccess: false,
                        serverUrl: '<SERVER_URL>'
                    ) {
                        sh "helm upgrade --install ${appName} springboot --set imageName=${ECR_REPO},imageTag=${IMAGE}"
                    }
                }
            }
        }

        stage('commit version') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-access-token', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "git config --global user.email 'jenkins@example.com'"
                        sh "git config --global user.name 'jenkins'"
                        sh "git remote set-url origin https://${USER}:${PASS}@github.com/Muffiuss/docker-spring-boot.git"
                        sh 'git add .'
                        sh 'git commit -m "[ci-skip] ci:version bump"'
                        sh 'git push origin HEAD:master'
                    }
                }
            }
        }

        stage('clean Workspace') {
            steps {
                cleanWs()
            }
        }
    }
}
