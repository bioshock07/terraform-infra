pipeline {
    agent any

    environment {
        PLAN_OUTPUT = ''
        HAS_DESTROY = false
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
                script {
                    PLAN_OUTPUT = sh(script: 'terraform plan -input=false -out=tfplan -var-file=terraform.tfvars', returnStdout: true)
                    echo PLAN_OUTPUT

                    if (PLAN_OUTPUT.contains("to destroy")) {
                        HAS_DESTROY = true
                    }

                    // Save to file to make available across later stages
                    writeFile file: 'has_destroy.txt', text: "${HAS_DESTROY}"
                    writeFile file: 'plan_summary.txt', text: PLAN_OUTPUT.readLines().find { it.contains("to add") || it.contains("to destroy") || it.contains("to change") } ?: "No summary found"
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression {
                    return fileExists('has_destroy.txt') && readFile('has_destroy.txt').trim() == 'true'
                }
            }
            steps {
                echo "⚠️ Planned destruction:"
                echo readFile('plan_summary.txt')
            }
        }

        stage('Apply Plan (Confirmation)') {
            steps {
                script {
                    def proceed = input(
                        id: 'ApplyApproval',
                        message: 'Terraform plan complete. Proceed with apply?',
                        parameters: [booleanParam(defaultValue: false, description: 'Apply the plan?', name: 'CONFIRM_APPLY')]
                    )
                    if (!proceed) {
                        error("❌ User aborted.")
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                echo "🚀 Applying the plan now..."
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully."
        }
        failure {
            echo "❌ Pipeline failed."
        }
        always {
            sh 'rm -f tfplan has_destroy.txt plan_summary.txt || true'
        }
    }
}
