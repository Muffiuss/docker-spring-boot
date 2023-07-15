pipeline {
    agent any
    tools {
        maven 'Maven'
    }
    environment {
        ECR_REPO = "${ECR_SERVER}/spring-boot-app"
        ECR_SERVER = '874503558975.dkr.ecr.us-east-1.amazonaws.com'
        appName = 'springbootapp'
        IMAGE = "${VERSION}-${BUILD_NUMBER}"
    }

        stages {
            stage('increment version') {
                steps {
                    script {
                        sh "mvn build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} versions:commit"
                        def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                        def VERSION = matcher[0][1]
                        
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
                      withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'springboot-K8S', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                        sh " helm upgrade --install /var/lib/jenkins/workspace/springboot-app_master/springboot --set imageName=${ECR_REPO} ,imageTag=${IMAGE}"
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