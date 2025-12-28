pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "bhavyank99/flask-app:latest"
        AWS_REGION   = "eu-north-1"
        // It is better to define these here so you don't have to change them in every stage
        DOCKER_REGISTRY_CRED_ID = 'dockerhub-creds'
        AWS_CRED_ID             = 'aws-creds' // You need to create this in Jenkins
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/BhavyankVith/jenkins-terraform-k8s-cicd.git'
            }
        }
    
        stage('Build Docker Image') {
            steps {
                // Use env variable for consistency
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        // stage('Push Docker Image') {
        //     steps {
        //         withCredentials([usernamePassword(
        //             credentialsId: "${DOCKER_REGISTRY_CRED_ID}",
        //             usernameVariable: 'DOCKER_USER',
        //             passwordVariable: 'DOCKER_PASS'
        //         )])
        //          {
        //             // Using single quotes prevents Groovy from expanding the variables prematurely
        //             sh '''
        //             echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
        //             docker push $DOCKER_IMAGE
        //             '''
        //         }
        //     }
        // }
        //Try another approach
stage('Push Docker Image') {
    steps {
        // Use usernamePassword to get two separate variables
        withCredentials([usernamePassword(
            credentialsId: 'dd5363fb-0a87-45e1-8c1c-7ea77575b4e0', 
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
        )]) {
            // The shell script MUST be inside these curly braces
            sh '''
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            docker push $DOCKER_IMAGE
            '''
        }
    }
}
        // stage('Provision Infra with Terraform') {
        //     steps {
        //         // Wrap in AWS credentials so Terraform can talk to AWS
        //         withCredentials([[
        //             $class: 'AmazonWebServicesCredentialsBinding', 
        //             credentialsId: "${AWS_CRED_ID}", 
        //             accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
        //             secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        //         ]])
                
        //          {
        //             dir('terraform') {
        //                 sh '''
        //                 terraform init
        //                 terraform apply -auto-approve
        //                 '''
        //             }
        //         }
        //     }
        // }
    // New syntax
stage('Provision Infra with Terraform') {
    steps {
        withCredentials([aws(
            credentialsId: 'aws-creds', 
            accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        )]) {
            dir('terraform') {
            sh '''
            export PATH=$PATH:/usr/local/bin:/opt/homebrew/bin
            terraform init -input=false
            terraform apply \
            -var="region=eu-north-1" \
            -var="cluster_name=my-eks-cluster" \
            -var='subnet_ids=["subnet-0123456789abcdef0", "subnet-0987654321fedcba0"]' \
            -input=false -auto-approve
            '''
            }
        }
    }
}
        stage('Deploy to Kubernetes') {
            steps {
                // You must ensure your environment has the right kubeconfig
                // If using EKS, you can refresh it here:
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    credentialsId: "${AWS_CRED_ID}", 
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    aws eks update-kubeconfig --region eu-north-1 --name demo-eks
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Please check the logs above."
        }
    }
}
// Previous jenkins file
// pipeline {
//     agent any

//     environment {
//         DOCKER_IMAGE = "bhavyank99/flask-app:latest"
//         AWS_REGION   = "eu-north-1"
//     }

//     stages {

//         stage('Checkout Code') {
//             steps {
//                 git branch: 'main', url: 'https://github.com/BhavyankVith/jenkins-terraform-k8s-cicd.git'
//             }
//         }

//         stage('Build Docker Image') {
//             steps {
//                 sh "docker build -t $DOCKER_IMAGE ."
//             }
//         }

//         stage('Push Docker Image') {
//             steps {
//                 withCredentials([usernamePassword(
//                     credentialsId: 'dockerhub-creds',
//                     usernameVariable: 'DOCKER_USER',
//                     passwordVariable: 'DOCKER_PASS'
//                 )]) {
//                     sh """
//                     echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
//                     docker push $DOCKER_IMAGE
//                     """
//                 }
//             }
//         }

//         stage('Provision Infra with Terraform') {
//             steps {
//                 dir('terraform') {
//                     sh """
//                     terraform init
//                     terraform apply -auto-approve
//                     """
//                 }
//             }
//         }

//         stage('Deploy to Kubernetes') {
//             steps {
//                 sh """
//                 kubectl apply -f k8s/deployment.yaml
//                 kubectl apply -f k8s/service.yaml
//                 """
//             }
//         }
//     }

//     post {
//         success {
//             echo "✅ Deployment completed successfully!"
//         }
//     }
// }
