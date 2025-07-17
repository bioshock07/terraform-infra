pipeline {
    agent any

    environment {
        PLAN_SUMMARY = ""
        HAS_ADD = false
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
                    PLAN_SUMMARY = sh(
                        script: 'terraform plan -input=false -out=tfplan -var-file=terraform.tfvars',
                        returnStdout: true
                    )

                    echo PLAN_SUMMARY

                    // Check plan summary lines
                    if (PLAN_SUMMARY.contains("to add") && PLAN_SUMMARY =~ /(\d+) to add/ && PLAN_SUMMARY.find(/(\d+) to add/){ it.split(" ")[0].toInteger() > 0 }) {
                        HAS_ADD = true
                    }

                    if (PLAN_SUMMARY.contains("to destroy") && PLAN_SUMMARY =~ /(\d+) to destroy/ && PLAN_SUMMARY.find(/(\d+) to destroy/){ it.split(" ")[0].toInteger() > 0 }) {
                        HAS_DESTROY = true
                    }

                    // Show quick summary
                    def summaryLine = PLAN_SUMMARY.readLines().find { it.contains("to add") || it.contains("to change") || it.contains("to destroy") }
                    echo "🔍 Plan Summary: ${summaryLine ?: 'No changes detected'}"
                }
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
            when {
                expression { return HAS_ADD }
            }
            steps {
                echo "🚀 Resources to be created/updated. Applying..."
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { return HAS_DESTROY }
            }
            steps {
                echo "💣 Resources marked for destruction:"
                def destroyLine = PLAN_SUMMARY.readLines().find { it.contains("to destroy") }
                echo destroyLine ?: "Nothing to destroy."
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
    }
}
