locals {
  task_definition = data.terraform_remote_state.bananas.outputs.task_definition_bananas-web
}

# keeping aroudn for disucssion
import {
  to = aws_ecs_task_definition.bananas
  id = "arn:aws:ecs:eu-west-1:205899621967:task-definition/bananas-bananas-web-production:3"
}

resource "aws_ecs_task_definition" "bananas" {
  # for_each over ecs_task_definitions map allows adding
  # more services in the future easily and uniformly

  family                   = local.task_definition.base_parameters.family
  network_mode             = local.task_definition.base_parameters.network_mode
  requires_compatibilities = local.task_definition.base_parameters.requires_compatibilities

  cpu    = local.task_definition.base_parameters.cpu
  memory = local.task_definition.base_parameters.memory


  # task execution role assumed by Fragate and ECS agent
  execution_role_arn = local.task_definition.base_parameters.execution_role_arn

  # role assumed by the task
  task_role_arn = local.task_definition.base_parameters.task_role_arn

  container_definitions = jsonencode(concat([
    {
      name = local.task_definition.container_definition.name

      image = local.image # <<--- udpate the image

      essential         = true
      cpu               = local.task_definition.container_definition.cpu
      memoryReservation = local.task_definition.container_definition.memory_reservation
      portMappings      = lookup(local.task_definition.container_definition, "port_mappings", [])
      command           = local.task_definition.container_definition.command
      entryPoint        = lookup(local.task_definition.container_definition, "entry_point", [])

      environment = [
        for name, value in {
          ENVIRONMENT = var.environment
        } :
        { name = name, value = tostring(value) }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = local.task_definition.log_options.awslogs_group
          awslogs-region        = local.task_definition.log_options.awslogs_region
          awslogs-stream-prefix = local.task_definition.log_options.awslogs_stream_prefix
        }
      }
    },
  ]))
}
