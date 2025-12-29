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
        retry(3) { // Jenkins will try again up to 3 times if there is a network error
    sh '''
        export PATH=$PATH:/usr/local/bin:/opt/homebrew/bin
        terraform init -input=false
        
        # --- NEW IMPORT STEP ---
        # This tells Terraform: "Hey, I know 'flask-app-nodes' already exists. Add it to your state file."
        # The '|| true' ensures that if it's ALREADY imported, the pipeline doesn't fail.
        terraform import \
          -var="region=${AWS_REGION}" \
          -var="cluster_name=my-eks-cluster" \
          -var='subnet_ids=["subnet-0167de52b93fdb411", "subnet-06606047d9e755830"]' \
          aws_eks_node_group.nodes my-eks-cluster:flask-app-nodes || true

        # --- EXISTING APPLY STEP ---
        terraform apply \
          -var="region=${AWS_REGION}" \
          -var="cluster_name=my-eks-cluster" \
          -var='subnet_ids=["subnet-0167de52b93fdb411", "subnet-06606047d9e755830"]' \
          -input=false -auto-approve
        '''
                }
            }
        }
    }
}
stage('Deploy to Kubernetes') {
    steps {
        // Ensure credentialsId matches your stored Jenkins credential ID
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding', 
            credentialsId: 'aws-creds', // Using the ID that worked in the previous stage
            accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
            sh '''
            # 1. Update name from 'demo-eks' to 'my-eks-cluster'
            aws eks update-kubeconfig --region eu-north-1 --name my-eks-cluster
            
            # 2. Apply your Kubernetes manifests
            kubectl apply -f k8s/deployment.yaml
            kubectl apply -f k8s/service.yaml
            echo "--- Verification ---"
            kubectl get nodes
            kubectl get pods
            kubectl get svc flask-service
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
