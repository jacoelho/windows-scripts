Function Create-RandomPassword {
  $Length = "10" #number of characters
  $NonAlpha = "2" #Number of non alphanumerical characters
  [Reflection.Assembly]::LoadWithPartialName(“System.Web”) | Out-Null
  [System.Web.Security.Membership]::GeneratePassword($Length,$NonAlpha)
}

