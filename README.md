# Docker file for angular PWA
- nodejs 12
- chrome (E2E protractor test)
- firebase (deploy to firebase hosting)
- @angular/cli

# Setup gitlab runner
    To register a Runner under GNU/Linux:

    Run the following command:

        sudo gitlab-runner register

    Enter your GitLab instance URL:

        Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com )
        https://gitlab.com

    Enter the token you obtained to register the Runner:

        Please enter the gitlab-ci token for this runner
        xxx

    Enter a description for the Runner, you can change this later in GitLab’s UI:

        Please enter the gitlab-ci description for this runner
        [hostname] my-runner

    Enter the tags associated with the Runner, you can change this later in GitLab’s UI:

        Please enter the gitlab-ci tags for this runner (comma separated):
        my-tag,another-tag

    Enter the Runner executor:

        Please enter the executor: docker

    If you chose Docker as your executor, you’ll be asked for the default image to be used for projects that do not define one in .gitlab-ci.yml:

    Please enter the Docker image (eg. ruby:2.6): vuhung3990/angular-chrome:lastest
#   example .gitlab-ci.yml
    local:
      artifacts:
        when: on_success
        paths:
          - output
      before_script:
        - npm install
      only:
        - review
      script:
        - ng lint
        - ng test --no-watch --no-progress --browsers=ChromeHeadlessCI --source-map=false
        - ng e2e --protractor-config=e2e/protractor.conf.js --configuration=local

        # versioning on review only, increase version on another branch is unnecessary.
        - git config user.email "CI@gitlab.com"
        - git config user.name "CI bot"
        # this file changes ussually, it's fine to discard this file
        - git checkout -- package-lock.json
        - npm version minor
        
        # push lastest changes to host
        #- ng build --configuration=local --output-path=output --delete-output-path
        #- sshpass -p $LOCAL_DEPLOY_PASSWORD scp -o stricthostkeychecking=no -r output/* ${LOCAL_DEPLOY_USER}@${LOCAL_DEPLOY_HOST}:/deploy/pwa/
        
        # pull lastest changes
        - git pull http://$USER_NAME:$PERSONAL_ACCESS_TOKEN@$REPO_GIT review
        ## --follow-tags: push tags
        ## --push-option=ci.skip: skip CI build
        - git push --follow-tags --push-option=ci.skip http://$USER_NAME:$PERSONAL_ACCESS_TOKEN@$REPO_GIT HEAD:review

        # deploy firebase hosting
        - ng build  --delete-output-path --output-path=public --configuration=staging&&firebase deploy
