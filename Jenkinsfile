
def getServerUrl() {
    if (params.DEPLOY_ENV == 'DEV') {
        return env.DEV_K8S_URL 
    } else if (params.DEPLOY_ENV == 'STAGE') {
        return env.STAGE_K8S_URL
    } else if (params.DEPLOY_ENV == 'PROD') {
        return env.PROD_K8S_URL
    } else {
        error("Unknown DEPLOY_ENV: ${params.DEPLOY_ENV}")
    }
}

def VERSION

pipeline {
    agent any
    tools {
        maven 'Maven'
    }

    parameters {
        choice(
            name: 'DEPLOY_ENV',
            choices: ['DEV', 'STAGE', 'PROD'],
            description: 'The target environment'
        )
    }

    environment {
        DEV_K8S_URL = 'https://9F4C603BF6FEE994C36A61151A72F2B7.gr7.us-east-1.eks.amazonaws.com'
        STAGE_K8S_URL = 'https://B315EA83323C15E4655107BB46BF9686.gr7.us-east-1.eks.amazonaws.com'
        PROD_K8S_URL = 'https://2B65C0B147DC881DA5DBD12467901DB2.yl4.us-east-1.eks.amazonaws.com'

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
                    def credentialsId = "${params.DEPLOY_ENV}-springboot-K8S" 
                     def serverUrl = getServerUrl()  
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: credentialsId, namespace: '', restrictKubeConfigAccess: false, serverUrl: serverUrl) {
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
