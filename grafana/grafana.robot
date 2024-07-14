# Very gratefully inspired from devopsspiral. See: https://github.com/devopsspiral/KubeLibrary/blob/master/testcases/grafana/demo-UI-test.robot
# Thank you!
*** Settings ***
Library          KubeLibrary
Library          Browser
Library          Collections
Library          RequestsLibrary
Variables    config.yml

Documentation    This Test checks if the grafana deployment is working in kubernetes
...              And if there is data from the node exporter

*** Test Cases ***
Check Grafana Installation
    Check Grafana Deployment Exists
    Check Replica Status
    Grafana Pods Are Running
    Check Grafana Service
    Check Grafana Secrets
    Check Grafana Serviceaccounts

Get Grafana Secrets and URL
    Get URL From Ingress
    Read Grafana Secrets

Check Data In Grafana
    Set Browser Timeout    1m 30 seconds
    Login To Grafana
    Check Data Source Metrics Are Available

*** Keywords ***
Check Grafana Deployment Exists
    @{namespace_deployments}=  List Namespaced Deployment By Pattern    grafana  ${grafana_namespace}
    Length Should Be  ${namespace_deployments}  1
    FOR  ${deployment}  IN  @{namespace_deployments}
        Should be Equal   ${deployment.metadata.name}  grafana
        Set Global Variable  ${DEPLOYMENT}  ${deployment}
    END

Check Replica Status
    Should be Equal  ${DEPLOYMENT.status.available_replicas}  ${DEPLOYMENT.status.replicas}
    ...  msg=Available replica count (${DEPLOYMENT.status.available_replicas}) doesn't match current replica count (${DEPLOYMENT.status.replicas}

Grafana Pods Are Running
    Wait Until Keyword Succeeds    1min    5sec   Check grafana pod status

Check Grafana pod status
    @{namespace_pods}=    List Namespaced Pod By Pattern    grafana    ${grafana_namespace}
    Length Should Be  ${namespace_pods}  1
    FOR    ${pod}    IN    @{namespace_pods}
        ${status}=    Read Namespaced Pod Status    ${pod.metadata.name}    ${grafana_namespace}
        Should Be True     '${status.phase}'=='Running'
    END

Check Grafana Service
    ${sevice_details}=  Read Namespaced Service  grafana  ${grafana_namespace}
    Dictionary Should Contain Item    ${sevice_details.metadata.labels}    app.kubernetes.io/name  grafana
    ...  msg=Expected labels do not match.
    Should Be Equal    ${sevice_details.spec.type}    ${grafana_service_type}
    ...  msg=Expected service type does not match.

Check Grafana Secrets
    @{namespace_secrets}=  List Namespaced Secret By Pattern    grafana  ${grafana_namespace}
    Length Should Be  ${namespace_secrets}  2

Check Grafana Serviceaccounts
    @{namespace_service_accounts}=  List Namespaced Service Account By Pattern    grafana  ${grafana_namespace}
    Length Should Be  ${namespace_service_accounts}  1
    FOR  ${service_account}  IN  @{namespace_service_accounts}
        Dictionary Should Contain Item    ${service_account.metadata.labels}    app.kubernetes.io/name  grafana
    END

Get URL From Ingress
    ${ingress}=     Read Namespaced Ingress    grafana  ${grafana_namespace}
    Set Global Variable  ${URL}  ${ingress.spec.rules[0].host}

Read Grafana Secrets
    Skip if    '${GRAFANA_USER}'!='None'
    Skip if    '${GRAFANA_PASSWORD}'!='None'
    @{namespace_secrets}=  List Namespaced Secret By Pattern    ^grafana$  ${grafana_namespace}
    Length Should Be  ${namespace_secrets}  1
    ${GRAFANA_USER}=  Evaluate  base64.b64decode($namespace_secrets[0].data["admin-user"])  modules=base64
    Set Global Variable  ${GRAFANA_USER}  ${GRAFANA_USER}
    ${GRAFANA_PASSWORD}=  Evaluate  base64.b64decode($namespace_secrets[0].data["admin-password"])  modules=base64
    Set Global Variable  ${GRAFANA_PASSWORD}  ${GRAFANA_PASSWORD}

Login To Grafana
    New Browser  chromium  headless=${True}
    New Page     https://${URL}
    Wait For Load State
    Fill Text    //input[@name='user']      ${GRAFANA_USER}
    Fill Text    //input[@name='password']  ${GRAFANA_PASSWORD}
    Click        text=Log in
    Wait For Load State
    Get Text     //h1  matches  Welcome to Grafana

Check Data Source Metrics Are Available
    New Page     https://${URL}/explore
    Click    id=option-code-radiogroup-13
    Click    .view-line
    Keyboard Input    insertText    ${TEST_QUERY}
    Sleep    1
    Click    //*[@id="pageContent"]/div[3]/div/div/div[1]/div/div[1]/div/div[1]/nav/div[2]/div[5]/div/button
    Wait For Load State
    Get Text    text=Result series:    >    0
