{{- define  "recursion2.valueTemplateRenderer" -}}
  {{ $output := dict }}
  {{- include "recursion2.valueTemplateRenderer.impl" (list .  .Values $output ) -}}
  {{ $_ := set . "ValuesRendered" $output.result }}
{{- end -}}


{{/*
  Recursively process the provided dictionary/array and apply tpl function to all string values.
  
  1st input  parameter is $root i.e., the `.`  in original caller contant that containes .Values, .Chart, .Capabilities etc, ...
  2nd input  parameter is object (dictionary, list, string, int, ... to be rendered. R
  3rd output parameter is Dictionary to which the result of this template call is stored under the result key.
*/}}
{{- define "recursion2.valueTemplateRenderer.impl" -}}
  {{- $root          :=  ( . | first ) -}}
  {{- $toRender      :=  ( . | rest | first ) -}}
  {{- $output        :=  ( . | rest | rest | first ) -}}

  {{- if kindIs "map"   $toRender -}}
    {{- $resultDict := dict -}} {{- /* Create dictionary where the recursively rendered content will be stored */ -}} 
    {{- range keys $toRender -}} {{- /* Recursively process all vales in the dictionary */ -}}
      {{- $key   := . -}}
      {{- $value := get $toRender $key -}}
      {{- $itemOutputDict := dict -}} {{- /* Creating dictionary where the recursive call will store its result */ -}}
      {{- include "recursion2.valueTemplateRenderer.impl" (list $root $value $itemOutputDict ) -}}
      {{ $_ := set $resultDict $key $itemOutputDict.result -}} {{- /* Copy recursively processes value to output dictionary */ -}}
    {{- end -}}
    {{- $_ := set $output "result" $resultDict -}} {{- /* Set the dict as ouptut of this cuntion call */ -}}

  {{- else if kindIs "slice" $toRender -}}  
    {{- /* List - recursively apply recursively the template to all list elements */ -}} 

    {{- $resultHolder := (dict  "list" list ) -}}  

    {{- /* Because appending to list produces new list + range creates new scope, we created a dictionary here with a single key "list" that hold result list */ -}}
    {{- range $toRender -}}
      {{- $value := . -}}
      {{- $itemOutputDict := dict -}}
      {{- include "recursion2.valueTemplateRenderer.impl" (list $root $value $itemOutputDict) -}}
      {{- $updatedList := append $resultHolder.list $itemOutputDict.result -}}
      {{- $_ := set $resultHolder "list" $updatedList -}}
    {{- end -}}
    {{- $_ := set $output "result" $resultHolder.list -}}

  {{- else if kindIs "string" $toRender -}}
    {{- /* String value - apply rendering */}}
    {{- $renderedValue := tpl $toRender $root -}}
    {{- $_ := set $output "result"  $renderedValue -}}

  {{- else -}}
    {{- /* int, null, - Copy the value as is */ -}}
    {{- $_ := set $output "result" $toRender -}}
  {{- end -}}
{{- end -}}


