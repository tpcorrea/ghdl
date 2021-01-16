# ==============================================================================
#  Authors:
#    Patrick Lehmann
#
# ==============================================================================
#  Copyright (C) 2017-2021 Patrick Lehmann - Boetzingen, Germany
#  Copyright (C) 2015-2016 Patrick Lehmann - Dresden, Germany
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <gnu.org/licenses>.
# ==============================================================================

# .SYNOPSIS
# Script to compile the UVVM libraries and verification models for GHDL on Windows.
#
# .DESCRIPTION
# This CmdLet:
#   (1) creates a subdirectory in the current working directory
#   (2) compiles all UVVM packages
#
[CmdletBinding()]
param(
	# Show the embedded help page(s).
	[switch]$Help =               $false,

	# Compile all packages.
	[switch]$All =                $false,

	# Compile all UVVM packages.
	[switch]$UVVM =               				$false,
		# Compile all UVVM Utility packages.
		[switch]$UVVM_UTIL =  		         	$false,
		# Compile all UVVM VCC Framework packages.
		[switch]$UVVM_VVC_FRAMEWORK =       $false,
	# Compile all UVVM Verification IPs (VIPs).
	[switch]$UVVM_VIP =           $false,
	  # Compile VIP: Avalon_MM
		[switch]$UVVM_VIP_AVALON_MM =       $false,
		# Compile VIP: Avalon_ST
		[switch]$UVVM_VIP_AVALON_ST =       $false,
		# Compile VIP: AXILITE
		[switch]$UVVM_VIP_AXILITE =         $false,
		# Compile VIP: AXISTREAM
		[switch]$UVVM_VIP_AXISTREAM =       $false,
		# Compile VIP: CLOCK_GENERATOR
		[switch]$UVVM_VIP_CLOCK_GENERATOR = $false,
		# Compile VIP: ERROR_INJECTION
		[switch]$UVVM_VIP_ERROR_INJECTION = $false,
		# Compile VIP: GMII
		[switch]$UVVM_VIP_GMII = 						$false,
		# Compile VIP: GPIO
		[switch]$UVVM_VIP_GPIO =            $false,
		# Compile VIP: I2C
		[switch]$UVVM_VIP_I2C =             $false,
		# Compile VIP: RGMII
		[switch]$UVVM_VIP_RGMII =						$false,
		# Compile VIP: SCOREBOARD
		[switch]$UVVM_VIP_SCOREBOARD =      $false,
		# Compile VIP: SBI
		[switch]$UVVM_VIP_SBI =             $false,
		# Compile VIP: SPI
		[switch]$UVVM_VIP_SPI =             $false,
		# Compile VIP: UART
		[switch]$UVVM_VIP_UART =            $false,
		# Compile VIP: HVVC_TO_VVC_BRIDGE
		[switch]$UVVM_VIP_HVVC_TO_VVC_BRIDGE = $false,
		# Compile VIP: ETHERNET
		[switch]$UVVM_VIP_ETHERNET = 				$false,
		# Compile VIP: AXI
		[switch]$UVVM_VIP_AXI = 						$false,
	# Clean up directory before analyzing.
	[switch]$Clean =              $false,

	#Skip warning messages. (Show errors only.)
	[switch]$SuppressWarnings =   $false,
	# Halt on errors.
	[switch]$HaltOnError =        $false,

	# Set vendor library source directory.
	[string]$Source =             "",
	# Set output directory name.
	[string]$Output =             "",
	# Set GHDL binary directory.
	[string]$GHDL =               ""
)

# ---------------------------------------------
# save working directory
$WorkingDir =     Get-Location

# set default values
$EnableDebug =    [bool]$PSCmdlet.MyInvocation.BoundParameters["Debug"]
$EnableVerbose =  [bool]$PSCmdlet.MyInvocation.BoundParameters["Verbose"] -or $EnableDebug

# load modules from GHDL's 'vendors' library directory
$EnableVerbose -and  (Write-Host "Loading modules..." -ForegroundColor Gray  ) | Out-Null
$EnableDebug -and    (Write-Host "  Import-Module $PSScriptRoot\config.psm1 -Verbose:`$$false -Debug:`$$false -ArgumentList `"UVVM`"" -ForegroundColor DarkGray  ) | Out-Null
Import-Module $PSScriptRoot\config.psm1 -Verbose:$false -ArgumentList "UVVM"
$EnableDebug -and    (Write-Host "  Import-Module $PSScriptRoot\shared.psm1 -Verbose:`$$false -Debug:`$$false -ArgumentList @(`"UVVM`", `"$WorkingDir`")" -ForegroundColor DarkGray  ) | Out-Null
Import-Module $PSScriptRoot\shared.psm1 -Verbose:$false -ArgumentList @("UVVM", "$WorkingDir")

# Display help if no command was selected
if ($Help -or (-not ($All -or $Clean -or
                    ($UVVM -or      ($UVVM_Utilities -or $UVVM_VVC_Framework)) -or
                    ($UVVM_VIP -or  ($UVVM_VIP_Avalon_MM -or $UVVM_VIP_AXI_Lite -or $UVVM_VIP_AXI_Stream -or
                                     $UVVM_VIP_Clock_Generator -or $UVVM_VIP_GPIO -or $UVVM_VIP_I2C -or $UVVM_VIP_SBI -or
                                     $UVVM_VIP_Scoreboard -or $UVVM_VIP_SPI -or $UVVM_VIP_UART))
	)))
{	Get-Help $MYINVOCATION.MyCommand.Path -Detailed
	Exit-CompileScript
}

if ($All)
{	$UVVM =                     $true
	$UVVM_VIP =                 $true
}
if ($UVVM)
{	$UVVM_UTIL =       			    $true
	$UVVM_VVC_FRAMEWORK =       $true
}
if ($UVVM_VIP)
{	$UVVM_VIP_AVALON_MM =       $true
	$UVVM_VIP_AVALON_ST =       $true
	$UVVM_VIP_AXILITE =         $true
	$UVVM_VIP_AXISTREAM =       $true
	$UVVM_VIP_CLOCK_GENERATOR = $true
	$UVVM_VIP_ERROR_INJECTION = $true
	$UVVM_VIP_GMII = 						$true
	$UVVM_VIP_GPIO =            $true
	$UVVM_VIP_I2C =             $true
	$UVVM_VIP_RGMII =						$true
	$UVVM_VIP_SCOREBOARD =      $true
	$UVVM_VIP_SBI =             $true
	$UVVM_VIP_SPI =             $true
	$UVVM_VIP_UART =            $true
	$UVVM_VIP_HVVC_TO_VVC_BRIDGE = $false
	$UVVM_VIP_ETHERNET = 				$true
	$UVVM_VIP_AXI = 						$true
}


$SourceDirectory =      Get-SourceDirectory $Source ""
$DestinationDirectory = Get-DestinationDirectory $Output
$GHDLBinary =           Get-GHDLBinary $GHDL

# create "uvvm" directory and change to it
New-DestinationDirectory $DestinationDirectory
cd $DestinationDirectory


$VHDLVersion,$VHDLStandard,$VHDLFlavor = Get-VHDLVariables

# define global GHDL Options
$GHDLOptions = @(
	"-a",
	"-fexplicit",
	"-frelaxed-rules",
	"--mb-comments",
	"-Wbinding"
)
if (-not $EnableDebug)
{	$GHDLOptions += @(
		"-Wno-hide"
	)
}
if (-not ($EnableVerbose -or $EnableDebug))
{ $GHDLOptions += @(
		"-Wno-others",
		"-Wno-static",
		"-Wno-shared"          # UVVM specific
	)
}
$GHDLOptions += @(
	"--ieee=$VHDLFlavor",
	"--no-vital-checks",
	"--std=$VHDLStandard",
	"-P$DestinationDirectory"
)


$StopCompiling =  $false
$ErrorCount =     0

# Cleanup directories
# ==============================================================================
if ($Clean)
{	Write-Host "[ERROR]: '-Clean' is not implemented!" -ForegroundColor Red
	Exit-CompileScript -1

	Write-Host "Cleaning up vendor directory ..." -ForegroundColor Yellow
	rm *.cf
}

Write-Host "Reading component list..." -ForegroundColor Cyan
$ModulesOrder = Get-Content "$SourceDirectory\script\component_list.txt"
foreach ($Line in $ModulesOrder)
{
		$EnableVerbose -and (Write-Host "  Found Module: $Line"    -ForegroundColor Gray                                                                ) | Out-Null
}

Write-Host "Reading Modules compile order files..." -ForegroundColor Cyan
$Module_Files = @{}
$ModuleNumber = 0
foreach ($line in $ModulesOrder)
{	$ModuleName =      $line
	if ($line.StartsWith("bitvis_"))
	{ $ModuleVariable =  "UVVM_" + $ModuleName.Substring(7).ToUpper()
		Write-Host "$ModuleVariable"
	}
	else
	{$ModuleVariable =  $ModuleName.ToUpper()
		Write-Host "$ModuleVariable"
	}

	$EnableVerbose -and (Write-Host "  Found Module: $ModuleName"    -ForegroundColor Gray                                                             ) | Out-Null
	$EnableDebug -and   (Write-Host "    Reading compile order from '$SourceDirectory\$ModuleName\script\compile_order.txt'" -ForegroundColor DarkGray ) | Out-Null

	$ModuleFiles = @()
	$CompileOrder = Get-Content "$SourceDirectory\$ModuleName\script\compile_order.txt"
	foreach ($Line in $CompileOrder)
	{	if ($Line.StartsWith("# "))
		{	if ($Line.StartsWith("# library "))
			{	$ModuleName = $Line.Substring(10) }
			else
			{ Write-Host "Unknown parser instruction in compile order file." -ForegroundColor Yellow }
		}
		else
		{	$Path = Resolve-Path "$SourceDirectory\$ModuleName\script\$Line"
			$ModuleFiles += $Path
		}
	}

	if ($EnableDebug)
	{	Write-Host "    VHDL Library name $ModuleNumber : $ModuleName"    -ForegroundColor DarkGray
		foreach ($File in $ModuleFiles)
	  {	Write-Host "      $File" -ForegroundColor DarkGray }
	}

	$Module_Files[$ModuleNumber] = @{
	  "Variable" =  "$ModuleVariable";
	  "Library" =    $ModuleName;
	  "Files" =      $ModuleFiles
	}
	$ModuleNumber = $ModuleNumber + 1
}

for ($vip= 0; $vip -le $ModuleNumber-1; $vip++) {
	if ((-not $StopCompiling) -and (Get-Variable $Module_Files[$vip]["Variable"] -ValueOnly))
	{
		$temp = $Module_Files[$vip]["Variable"]
			Write-Host "Variable $temp"
		$Library =      $Module_Files[$vip]["Library"]
		$SourceFiles =  $Module_Files[$vip]["Files"] #| % { "$SourceDirectory\$_" }

		$ErrorCount += Start-PackageCompilation $GHDLBinary $GHDLOptions $DestinationDirectory $Library $VHDLVersion $SourceFiles $SuppressWarnings $HaltOnError -Verbose:$EnableVerbose -Debug:$EnableDebug
		$StopCompiling = $HaltOnError -and ($ErrorCount -ne 0)
	}
}

Write-Host "--------------------------------------------------------------------------------"
Write-Host "Compiling UVVM packages " -NoNewline
if ($ErrorCount -gt 0)
{	Write-Host "[FAILED]" -ForegroundColor Red        }
else
{	Write-Host "[SUCCESSFUL]" -ForegroundColor Green  }

Exit-CompileScript
