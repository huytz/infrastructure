include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "huytz" {
  config_path = "../"
  mock_outputs = {
    project_id = "fake-project-id"
  }
}

inputs = {
  project_id = dependency.huytz.outputs.project_id
}
