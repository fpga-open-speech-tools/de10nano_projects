pipeline
{
    agent none
    stages
    {
        stage ('Ubuntu 20.04')
        {
            agent {label 'Ubuntu_20.04.1'}
            stages 
            {
                stage('Check DE10 Nano Projects') 
                {
                    parallel
                    {
                        stage('Audio Mini Passthrough')
                        {
                            when { changeset "AudioMini_Passthrough/*"}
                            steps 
                            {
                                build job: 'Q18P0_DE10_AudioMini_Passthrough'
                            }
                        }
                    }
                }
                stage('Cleanup')
                {
                    steps
                    {
                        deleteDir()
                        dir("${workspace}@tmp") {
                            deleteDir()
                        }
                    }
                } 
            }
        }
    }
}
