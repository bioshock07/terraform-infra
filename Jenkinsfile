pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        // Inject these from Jenkins Credentials (do not hardcode)
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'git@github.com:bioshock07/terraform-infra.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan.out'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan.out'
            }
        }
    }

    post {
        failure {
            echo 'Terraform pipeline failed ❌'
        }
        success {
            echo 'Terraform pipeline completed ✅'
        }
    }
}
