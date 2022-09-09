pipeline {
    agent {
        label 'ansible'
    }

    options {
        ansiColor('xterm')
        buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '10', artifactNumToKeepStr: '10'))
    }

    stages {
        stage('Run yamllint') {
            steps {
                sh 'yamllint --version'
                sh 'yamllint .'
            }
        }
        stage('Run ansible-lint') {
            steps {
                sh 'ansible-lint --version'
                sh 'ansible-lint'
            }
        }
    }
    post {
        always {
            cleanWs(deleteDirs: true)
        }
    }
}
