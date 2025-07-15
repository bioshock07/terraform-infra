pipeline {
    agent any

    environment {
        ACTION = ''
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
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
                sh 'terraform plan -input=false -out=tfplan -var-file=terraform.tfvars'
            }
        }

        stage('Select Action') {
            steps {
                script {
                    def userChoice = input(
                        id: 'ActionInput', message: 'Terraform plan completed successfully. Choose what to do next:', parameters: [
                            choice(choices: ['apply', 'destroy'], description: 'Select the operation to perform', name: 'ACTION')
                        ]
                    )
                    env.ACTION = userChoice
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { env.ACTION == 'apply' }
            }
            steps {
                input message: 'Confirm Apply?'
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { env.ACTION == 'destroy' }
            }
            steps {
                input message: 'Confirm Destroy?'
                sh 'terraform destroy -auto-approve -var-file=terraform.tfvars'
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully with action: ${env.ACTION}"
        }
        failure {
            echo "Pipeline failed during action: ${env.ACTION}"
        }
    }
}
