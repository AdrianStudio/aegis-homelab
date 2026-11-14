# Linter config. Run: tflint --init && tflint
plugin "terraform" {
  enabled = true
  preset  = "recommended" # catches unused variables, missing versions, etc.
}
