*** Settings ***
Library           KubeLibrary
Library           Collections
Variables         config.yml

*** Test Cases ***
Check Kubernetes Clusters Healthy
    Check Health of K8S

Check Pods Running
    Check Pod Existence And Health

*** Keywords ***
Check Health of K8S
    FOR    ${cluster}    IN    @{kubernetes_cluster}
        Reload Kubeconfig    ${cluster}
        Get Healthcheck
        ${healthy_nodes}=    Get Healthy Nodes Count
        Should Be Equal    ${healthy_nodes}    ${cluster.number_of_nodes}
    END

Reload Kubeconfig
    [Arguments]    ${cluster}
    Reload Config    ${cluster['kubeconfig']}

Check Pod Existence And Health
    FOR    ${cluster}    IN    @{kubernetes_cluster}
        Reload Kubeconfig    ${cluster}
        FOR    ${expected_pod}    IN    @{cluster['pods']}
            ${running_pods}=    List Namespaced Pod By Pattern    ${expected_pod['name_pattern']}    ${expected_pod['namespace']}
            Length Should Be    ${running_pods}     ${expected_pod['required']}
            FOR    ${single_running_pod}    IN    @{running_pods}
                ${status}=    Read Namespaced Pod Status    ${single_running_pod.metadata.name}    ${single_running_pod.metadata.namespace}
                Should Be True     '${status.phase}'=='Running'
            END
        END
    END