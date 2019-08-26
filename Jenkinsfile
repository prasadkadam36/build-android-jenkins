node ('master'){
  //SCM Checkout
  stage('SCM Checkout'){
    git url: 'https://github.com/prasadkadam36/build-android-jenkins.git'
  }
   stage('Build Package'){
     
    def mvnHome = tool name: 'gradle-5.2.1', type: 'gradle'
     sh "${mvnHome}/bin/gradle build"
   }
  stage('Code-Analysis'){
    def mvnHome = tool name: 'gradle-5.2.1', type: 'gradle'
     withSonarQubeEnv('Sonar-7')
    {
      sh "${mvnHome}/bin/gradle sonarqube"
    }
   }
  stage("Quality Gate"){
          timeout(time: 1, unit: 'HOURS') {
              def qg = waitForQualityGate()
              if (qg.status != 'OK') {
                  error "Pipeline aborted due to quality gate failure: ${qg.status}"
              }
          }
      }        

  

   
}
