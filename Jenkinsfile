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
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { return HAS_DESTROY }
            }
            steps {
                script {
                    def destroyLine = PLAN_OUTPUT.readLines().find { it =~ /to destroy/ } ?: "Resources will be destroyed."
                    echo "⚠️ ${destroyLine}"
                }
            }
        }

        stage('Apply Plan') {
            steps {
                script {
                    def proceed = input(
                        id: 'ApplyApproval',
                        message: 'Terraform plan completed. Proceed with apply?',
                        parameters: [booleanParam(defaultValue: false, description: 'Apply the plan?', name: 'CONFIRM_APPLY')]
                    )
                    if (!proceed) {
                        error("❌ User aborted.")
                    }
                }
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully."
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
        always {
            sh 'rm -f tfplan || true'
        }
    }
}
