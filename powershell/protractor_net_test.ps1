
#Copyright (c) 2015 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

# https://github.com/bbaia/protractor-net/tree/master/src/Protractor
# https://github.com/anthonychu/Protractor-Net-Demo

param(
  [string]$browser = '',
  [switch]$grid,
  [switch]$pause
)




# 'C:\developer\sergueik\csharp\Protractor-Net-Demo-master\packages\Protractor.0.3.0\lib\net40'

# Setup 
$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'Protractor.dll',
  'nunit.framework.dll'
)

$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid -shared_assemblies $shared_assemblies

} else {
  $selenium = launch_selenium -browser $browser -shared_assemblies $shared_assemblies

}
[Protractor.NgWebDriver]$ng_driver = New-Object Protractor.NgWebDriver ($selenium)
$base_url = 'http://juliemr.github.io/protractor-demo/'

$selenium.Navigate().GoToUrl($base_url)

$ng_driver.Url = $base_url
$title = $ng_driver.Title
[NUnit.Framework.Assert]::AreEqual($title,"Super Calculator")

$first = $ng_driver.FindElement([Protractor.NgBy]::Input('first'))
$second = $ng_driver.FindElement([Protractor.NgBy]::Input('second'))
$goButton = $ng_driver.FindElement([OpenQA.Selenium.By]::Id('gobutton'))
$first.SendKeys("1")
$second.SendKeys("2")
$goButton.Click()
[int]$wait_seconds = 10
# Exception calling "FindElement" with "1" argument(s): "asynchronous script timeout: result was not received in 0 seconds
Start-Sleep -Millisecond 2000
# TODO : 
# [Protractor.ClientSideScripts.WaitForAngular]$wait = new-object Protractor.ClientSideScripts.WaitForAngular($ng_driver,[System.TimeSpan]::FromSeconds($wait_seconds))
# combining OpenQA.Selenium.Support.UI.WebDriverWait with Protractor.NgBy does not work

$latest_element = $ng_driver.FindElement([Protractor.NgBy]::Binding('latest'))

try {
  highlight ([ref]$selenium) ([ref]$latest_element) }
catch [exception]{
  Write-Debug ("Exception : {0}`n" -f (($_.Exception.Message) -split "`n")[0])
  # from OpenQA.Selenium.IJavaScriptExecutor
  # Exception calling "ExecuteScript" with "3" argument(s): "Argument is of anillegal typeProtractor.NgWebElement
}
[NUnit.Framework.Assert]::AreEqual($latest_element.Text,"3")
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

custom_pause -fullstop $fullstop

if (-not ($host.Name -match 'ISE')) {
  # Cleanup
  cleanup ([ref]$selenium)
}