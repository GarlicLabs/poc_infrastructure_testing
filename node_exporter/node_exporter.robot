*** Settings ***
Library           Process
Library           SSHLibrary
Suite Teardown    Close All Connections
Variables         config.yml

*** Variables ***
${SYSTEMD_RUNNING_SERVICES}    systemctl is-active node_exporter
${GET_PROCESS_NAME_FROM_PORT}    sudo ss -tlnp | grep ':9100' | awk '{print $6}' | cut -d '"' -f2-  | cut -d '"' -f 1  

*** Test Cases ***
Check if node exporter is running and open on correct port
    [Documentation]    Verify that the node exporter is running and listening on the correct port.
    FOR    ${server}    IN    @{servers}
        Connect To Server    ${server}
        ${output}=    Execute Command    ${SYSTEMD_RUNNING_SERVICES}
        Should Be Equal    ${output}    active
        ${output}=    Execute Command    ${GET_PROCESS_NAME_FROM_PORT}
        LOG    ${output}
        Should Be Equal    ${output}    node_exporter
    END


*** Keywords ***
Connect To Server
    [Arguments]    ${server}
    Open Connection    ${server['host']}    port=${server['port']}
    Login With Public Key    ${server['username']}    ${server['keyfile']}    ${server['key_password']}