output "task_definition" {
  value = data.terraform_remote_state.bananas.outputs.task_definition_bananas-web
}
