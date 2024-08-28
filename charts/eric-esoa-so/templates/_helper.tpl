{{/*
Expand the name of the chart.
*/}}
{{- define "eric-esoa-so.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the version of the chart.
*/}}
{{- define "eric-esoa-so.version" -}}
{{- default .Chart.Version .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create release name used for cluster role.
*/}}
{{- define "eric-esoa-so.release.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create release namespace.
*/}}
{{- define "eric-esoa-so.release.namespace" -}}
{{- default .Release.Namespace .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-esoa-so.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create image registry url
*/}}
{{- define "eric-esoa-so.registryUrl" -}}
{{- if .Values.imageCredentials.registry -}}
{{- if .Values.imageCredentials.registry.url -}}
{{- print .Values.imageCredentials.registry.url -}}
{{- else if .Values.global.registry.url -}}
{{- print .Values.global.registry.url -}}
{{- else -}}
""
{{- end -}}
{{- else if .Values.global.registry.url -}}
{{- print .Values.global.registry.url -}}
{{- else -}}
""
{{- end -}}
{{- end -}}

{{/*
Create Ericsson product app.kubernetes.io info
*/}}
{{- define "eric-esoa-so.kubernetes-io-info" -}}
app.kubernetes.io/name: {{ .Chart.Name | quote }}
app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{/*
Create Ericsson Product Info
*/}}
{{- define "eric-esoa-so.helm-annotations" -}}
ericsson.com/product-name: "Service Orchestration"
ericsson.com/product-number: "CXD 101 0748"
ericsson.com/product-revision: {{ regexReplaceAll "(.*)[+|-].*" .Chart.Version "${1}" | quote }}
{{- end}}

{{- define "eric-esoa-so.registryImagePullPolicy" -}}
    {{- $globalRegistryPullPolicy := "IfNotPresent" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.imagePullPolicy -}}
                {{- $globalRegistryPullPolicy = .Values.global.registry.imagePullPolicy -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if index .Values "imageCredentials" "registry" -}}
        {{- if index .Values "imageCredentials" "registry" "imagePullPolicy" -}}
        {{- $globalRegistryPullPolicy = index .Values "imageCredentials" "registry" "imagePullPolicy" -}}
        {{- end -}}
    {{- end -}}
    {{- print $globalRegistryPullPolicy -}}
{{- end -}}


{{/*
Create IAM-client image pull secrets
*/}}
{{- define "eric-esoa-so.iamClient.pullSecrets" -}}
    {{- if .Values.imageCredentials -}}
        {{- if .Values.imageCredentials.pullSecret -}}
            {{- print .Values.imageCredentials.pullSecret -}}
        {{- else if .Values.global.pullSecret -}}
            {{- print .Values.global.pullSecret -}}
        {{- end -}}
    {{- else if .Values.global.pullSecret -}}
        {{- print .Values.global.pullSecret -}}
    {{- end -}}
{{- end -}}

{{/*
Create IAM-client image registry url
*/}}
{{- define "eric-esoa-so.iamClient.registryUrl" -}}
  {{ if index .Values "imageCredentials" "iamClient" "registry" "url" -}}
    {{- print (index .Values "imageCredentials" "iamClient" "registry" "url") -}}
  {{- else -}}
    {{- print .Values.global.registry.url -}}
  {{- end -}}
{{- end -}}

{{- define "eric-esoa-so.iamClient.registryImagePullPolicy" -}}
    {{- $globalRegistryPullPolicy := "IfNotPresent" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.imagePullPolicy -}}
                {{- $globalRegistryPullPolicy = .Values.global.registry.imagePullPolicy -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if index .Values "imageCredentials" "iamClient" "registry" -}}
        {{- if index .Values "imageCredentials" "iamClient" "registry" "imagePullPolicy" -}}
        {{- $globalRegistryPullPolicy = index .Values "imageCredentials" "iamClient" "registry" "imagePullPolicy" -}}
        {{- end -}}
    {{- end -}}
    {{- print $globalRegistryPullPolicy -}}
{{- end -}}

{{- define "eric-esoa-so.bpmnWorkflowUpload.registryImagePullPolicy" -}}
    {{- $globalRegistryPullPolicy := "IfNotPresent" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.imagePullPolicy -}}
                {{- $globalRegistryPullPolicy = .Values.global.registry.imagePullPolicy -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if index .Values "imageCredentials" "bpmnWorkflowUpload" "registry" -}}
        {{- if index .Values "imageCredentials" "bpmnWorkflowUpload" "registry" "imagePullPolicy" -}}
        {{- $globalRegistryPullPolicy = index .Values "imageCredentials" "bpmnWorkflowUpload" "registry" "imagePullPolicy" -}}
        {{- end -}}
    {{- end -}}
    {{- print $globalRegistryPullPolicy -}}
{{- end -}}

{{/*
Enable Node Selector functionality
*/}}
{{- define "eric-esoa-so.nodeSelector" -}}
{{- if .Values.nodeSelector }}
nodeSelector:
  {{ toYaml .Values.nodeSelector | trim }}
{{- else if .Values.global.nodeSelector }}
nodeSelector:
  {{ toYaml .Values.global.nodeSelector | trim }}
{{- end }}
{{- end -}}

{{/*
The name of the cluster role used during openshift deployments.
This helper is provided to allow use of the new global.security.privilegedPolicyClusterRoleName if set, otherwise
use the previous naming convention of <release_name>-allowed-use-privileged-policy for backwards compatibility.
*/}}
{{- define "eric-esoa-so.privileged.cluster.role.name" -}}
  {{- if hasKey (.Values.global.security) "privilegedPolicyClusterRoleName" -}}
    {{ .Values.global.security.privilegedPolicyClusterRoleName }}
  {{- else -}}
    {{ template "eric-esoa-so.release.name" . }}-allowed-use-privileged-policy
  {{- end -}}
{{- end -}}

{{/*
Calculate if 'create-esd-nd-superuser-hook' should run, returns 'true' if it should.
Should not run if the installation is for the GR secondary site
*/}}
{{- define "eric-esoa-so.create-esd-nd-superuser-hook" -}}
  {{- $CREATE_HOOK := true }}
    {{- if index .Values "geo-redundancy"}}
      {{- if index .Values "geo-redundancy" "enabled" }}
        {{- if index .Values "eric-oss-common-base" }}
          {{- if index .Values "eric-oss-common-base" "eric-gr-bur-orchestrator" }}
            {{- if index .Values "eric-oss-common-base" "eric-gr-bur-orchestrator" "gr" }}
              {{- if index .Values "eric-oss-common-base" "eric-gr-bur-orchestrator" "gr" "cluster" }}
                {{- if index .Values "eric-oss-common-base" "eric-gr-bur-orchestrator" "gr" "cluster" "role" }}
                  {{- if eq  (index .Values "eric-oss-common-base" "eric-gr-bur-orchestrator" "gr" "cluster" "role") "SECONDARY" }}
                    {{- $CREATE_HOOK = false }}
                  {{- end }}
                {{- end }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- print $CREATE_HOOK -}}
{{ end}}

{{/*
check global.security.tls.enabled since it is removed from values.yaml
*/}}
{{- define "eric-esoa-so.global-security-tls-enabled" -}}
{{- if  .Values.global -}}
  {{- if  .Values.global.security -}}
    {{- if  .Values.global.security.tls -}}
       {{- .Values.global.security.tls.enabled | toString -}}
    {{- else -}}
       {{- "false" -}}
    {{- end -}}
  {{- else -}}
       {{- "false" -}}
  {{- end -}}
{{- else -}}
{{- "false" -}}
{{- end -}}
{{- end -}}

{{/*
Create external CA secret name
*/}}
{{- define "caSecret.name" -}}
{{ template "eric-esoa-so.name" . }}-ca-external-cert
{{- end -}}

{{/*
The soBaseImage path
*/}}
{{- define "baseImage.mainImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.soBaseImage.registry -}}
    {{- $repoPath := $productInfo.images.soBaseImage.repoPath -}}
    {{- $name := $productInfo.images.soBaseImage.name -}}
    {{- $tag := $productInfo.images.soBaseImage.tag -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if .Values.imageCredentials.soBaseImage -}}
            {{- if .Values.imageCredentials.soBaseImage.registry -}}
                {{- if .Values.imageCredentials.soBaseImage.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.soBaseImage.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if .Values.global.registry.repoPath -}}
                {{- $repoPath = .Values.global.registry.repoPath -}}
            {{- else if .Values.imageCredentials.soBaseImage.repoPath -}}
                {{- $repoPath = .Values.imageCredentials.soBaseImage.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
Create the FQDN url to be used by the SO services
*/}}
{{- define "eric-esoa-so.fqdn" -}}
{{- $fqdnPrefix := .Values.ingress.fqdnPrefix -}}
{{- $chartName := .Chart.Name -}}
{{- if index .Values.global.hosts $chartName  -}}
  {{- $fqdn := index .Values.global.hosts $chartName -}}
  {{- printf "%s" $fqdn }}
{{- else -}}
  {{- $baseHostname := .Values.global.ingress.baseHostname | required "global.ingress.baseHostname is mandatory" -}}
  {{- printf "%s.%s" $fqdnPrefix $baseHostname }}
{{- end -}}
{{- end -}}

{{/*
Create the FQDN url for EOC Admin to be used to integrate SO with EOC
*/}}
{{- define "eric-esoa-eoc.fqdn" -}}
{{- $fqdnPrefix := .Values.eoc.eocAdmin.fqdnPrefix -}}
{{- $baseHostname := .Values.global.ingress.baseHostname | required "global.ingress.baseHostname is mandatory" -}}
{{- printf "%s.%s" $fqdnPrefix $baseHostname }}
{{- end -}}

{{/*
Create the ingressClass to be used by the SO services
*/}}
{{- define "eric-esoa-so.ingressClass" -}}
{{- if .Values.ingress.ingressClass -}}
  {{- printf "%s" .Values.ingress.ingressClass }}
{{- else -}}
  {{- $ingressClass := .Values.global.ingress.ingressClass | required "global.ingress.ingressClass is mandatory" -}}
  {{- printf "%s" $ingressClass }}
{{- end -}}
{{- end -}}

{{/*
TLS args to curl command if TLS is on
*/}}
{{- define "eric-esoa-so.create-esd-superuser-hook.tls.args" -}}
  {{- $tlsArgs := "" -}}
  {{- if eq (include "eric-esoa-so-library-chart.global-security-tls-enabled" .) "true" -}}
    {{- $path := .Values.security.keystore.tlsCertDirectory -}}
    {{- $tlsCertFile := .Values.security.keystore.tlsCertFile -}}
    {{- $tlsKeyFile := .Values.security.keystore.tlsKeyFile -}}
    {{- $tlsArgs = printf "--cert %s%s --key %s%s" $path $tlsCertFile $path $tlsKeyFile -}}
  {{- end -}}
  {{- printf $tlsArgs -}}
{{- end -}}

{{/*Check for ctsSecret*/}}
{{- define "check-for-ctsSecret-exist" -}}
  {{- $ctsSecretKeyName := index . "ctsSecretKeyName" | toString -}}
  {{- $ctsName:= .Values.ctsCredentialsSecret.name -}}
  {{- $ctsSecret:= lookup "v1" "Secret" .Release.Namespace $ctsName -}}
  {{- if (index $ctsSecret "data") -}}
    {{- if (index $ctsSecret "data" $ctsSecretKeyName) -}}
       {{ printf "%s" (index $ctsSecret "data" $ctsSecretKeyName) -}}
    {{- end }}
  {{- end -}}
{{- end -}}


{{/*Get ctsSecret username*/}}
{{- define "get-ctsSecret-username" -}}
  {{- $ctsUsername := include "check-for-ctsSecret-exist" (merge (dict "ctsSecretKeyName" .Values.ctsCredentialsSecret.usernameKey) . ) -}}
  {{- if $ctsUsername -}}
    {{- printf $ctsUsername | b64dec -}}
  {{- else -}}
    {{ printf "sysadm"}}
  {{- end -}}
{{- end -}}


{{/*Get ctsSecret password*/}}
{{- define "get-ctsSecret-password" -}}
  {{- $ctsPassword := include "check-for-ctsSecret-exist" (merge (dict "ctsSecretKeyName" .Values.ctsCredentialsSecret.passwordKey) .) -}}
  {{- if $ctsPassword -}}
    {{- printf $ctsPassword | b64dec -}}
  {{- end -}}
{{- end -}}

{{/*Set encrypt ctsSecret credentials*/}}
{{- define "eric-oss-cmn-topology-svc-core-adminuser-credentials" -}}
  {{ $ctsPassword :=  ""}}
  {{- $ctsUsername :=  include "get-ctsSecret-username" . | trim -}}
  {{- $ctsPassword =  include "get-ctsSecret-password" . | trim -}}
  {{- (printf "%s:%s" $ctsUsername $ctsPassword) | b64enc -}}
{{- end -}}