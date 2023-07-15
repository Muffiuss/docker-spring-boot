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
                        caCertificate: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJek1EY3hOVEU0TVRVd00xb1hEVE16TURjeE1qRTRNVFV3TTFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTWpQCjZ1UmlkM1ByN1IxVkxVbWFKSXlwMExDaENUMkZGVjBHVzhsNWR4cEcwQVpGUFZ4ZlNRSUcxUG1SakdOV2RNZzQKaDRpbDd0WTVaN1JLQmgxY3J6YUNQTDA0OG11RERtZmEvZ3FkTkEyYmc3bEpCS1lzbDRCVGJxTElIcWhTRkFSZgpzWjRVUXhPTmNkUnI2QWtFekJ3OFN2b0pXUXAxVzUvNTYxUUZZL2UwTjh3alRxVnErNXlVNVpDL0VEUnkyeHJJCmRxd05IRk9SdGZXS3ZNK2hGVkFLSWRrTjJvNVdzY093OTc1L1pSdWpJMnl6Mmd1RWlId2o3dkJQZjlBWitsZTEKZm00T0VOODdFRjdMMWd2RWkvV0RxM1VlYXNOU1YvKzMyNTFQQ1o2bTFMeWVjdjA5L2RkM1pIcTZMcno1Wm1rSQpLVklhSXJpRy9DWGM4ZW5JUDdNQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZJMmlZM2VJbkV2SW1wckhpN0YvMUFqbENDYjVNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBR3Q3L3RmYS9XeTRLaWYxaS9kcQpoZWdiWUVobXd0WWZjSXEvZzhGUUZhOUZWbFNYczJhNXUvNkJpV3lFbzNORG9XeXpyYW5aYUpuZElPUEZzVHB5CmZLTVpQa0czbzM0MitmUnA5U2xBWjY2azB5Nk02cWwvZEoyUWxOcklCZHdoVGt3T0g4bWRBS04vNi85SWRHVnQKYUNtWjMxWGgxYWtsSHA1UlhRUW9NVGtTeVRZVEM2S2hCOUc5aUJwUitQVTQvaXpDNVNRUGF5NnE1TUd3ckE4dgpXRjlORW1YSHhibEcvRzFVcWZzalJ5K3VrTkd4UlpRTXowMUNscEdVQjlhZy9nSW83VkwrY1BoS1E2VXVWTHpkCjJGWjVFMThTQzRYYSt2a2IyZk9kNFY3bTBXN3BtSjlPaU9keG13SGduWVdtK1R4REFIZlJmSjV6S2p1R2JTbTIKdStNPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==',
                        clusterName: '<CLUSTER_NAME>',
                        contextName: '<CONTEXT_NAME>',
                        credentialsId: 'springboot-K8S',
                        namespace: '<NAMESPACE>',
                        restrictKubeConfigAccess: false,
                        serverUrl: 'https://9F4C603BF6FEE994C36A61151A72F2B7.gr7.us-east-1.eks.amazonaws.com'
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
