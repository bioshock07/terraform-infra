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
                        id: 'ActionInput',
                        message: 'Terraform plan completed successfully. What do you want to do next?',
                        parameters: [
                            choice(choices: ['apply', 'destroy'], description: 'Choose the operation to perform', name: 'ACTION')
                        ]
                    )
                    writeFile file: 'selected_action.txt', text: userChoice
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression {
                    return fileExists('selected_action.txt') &&
                           readFile('selected_action.txt').trim() == 'apply'
                }
            }
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression {
                    return fileExists('selected_action.txt') &&
                           readFile('selected_action.txt').trim() == 'destroy'
                }
            }
            steps {
                sh 'terraform destroy -auto-approve -var-file=terraform.tfvars'
            }
        }
    }

    post {
        success {
            script {
                def action = fileExists('selected_action.txt') ? readFile('selected_action.txt').trim() : 'N/A'
                echo "Pipeline completed successfully with action: ${action}"
            }
        }
        failure {
            script {
                def action = fileExists('selected_action.txt') ? readFile('selected_action.txt').trim() : 'N/A'
                echo "Pipeline failed during action: ${action}"
            }
        }
    }
}
