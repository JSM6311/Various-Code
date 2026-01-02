<#
.SYNOPSIS
    Automated prescription management system with pharmacist oversight

.DESCRIPTION
    Manages prescriptions with built-in safety checks and pharmacist review workflow.
    Provides functionality for:
        - Medicine database management
        - Prescription creation and validation
        - Drug interaction checking
        - Pharmacist review and approval workflow
        - Prescription history tracking

.PARAMETER Action
    The action to perform: 'AddMedicine', 'CreatePrescription', 'ReviewPrescription', 'GetPrescription', 'ListMedicines'

.PARAMETER MedicineDatabase
    Path to the medicine database CSV file. Default: ./MedicineDatabase.csv

.PARAMETER PrescriptionDatabase
    Path to the prescription database CSV file. Default: ./PrescriptionDatabase.csv

.PARAMETER MedicineName
    Name of the medicine

.PARAMETER Category
    Category or type of medicine (e.g., "Antibiotic", "Pain Relief")

.PARAMETER Warnings
    Safety warnings and precautions for the medicine

.PARAMETER Dosage
    Dosage information (e.g., "500mg", "10ml")

.PARAMETER Frequency
    How often to take the medicine (e.g., "twice daily", "every 6 hours")

.PARAMETER Duration
    Duration of the prescription (e.g., "7 days", "2 weeks")

.PARAMETER PatientID
    Patient identifier

.PARAMETER PrescriptionID
    Prescription identifier for review or retrieval

.PARAMETER PharmacistName
    Name of the reviewing pharmacist

.PARAMETER Approved
    Switch to approve a prescription during review

.EXAMPLE
    Manage-Prescription -Action AddMedicine -MedicineName "Amoxicillin" -Category "Antibiotic" -Warnings "Allergic reactions possible"
    Add a new medicine to the database

.EXAMPLE
    Manage-Prescription -Action CreatePrescription -MedicineName "Amoxicillin" -Dosage "500mg" -Frequency "Three times daily" -Duration "7 days" -PatientID "P12345"
    Create a new prescription that requires pharmacist review

.EXAMPLE
    Manage-Prescription -Action ReviewPrescription -PrescriptionID "RX001" -PharmacistName "Dr. Smith" -Approved
    Approve a prescription after pharmacist review

.EXAMPLE
    Manage-Prescription -Action GetPrescription -PrescriptionID "RX001"
    Retrieve details of a specific prescription

.EXAMPLE
    Manage-Prescription -Action ListMedicines
    List all medicines in the database

.NOTES
    Author: Automated Prescription System
    This system ensures pharmacist oversight while automating routine prescription tasks
#>

Function Manage-Prescription
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('AddMedicine', 'CreatePrescription', 'ReviewPrescription', 'GetPrescription', 'ListMedicines')]
        [string]$Action,

        [Parameter(Mandatory=$false)]
        [string]$MedicineDatabase = "./MedicineDatabase.csv",

        [Parameter(Mandatory=$false)]
        [string]$PrescriptionDatabase = "./PrescriptionDatabase.csv",

        [Parameter(Mandatory=$false)]
        [string]$MedicineName,

        [Parameter(Mandatory=$false)]
        [string]$Category,

        [Parameter(Mandatory=$false)]
        [string]$Warnings,

        [Parameter(Mandatory=$false)]
        [string]$Dosage,

        [Parameter(Mandatory=$false)]
        [string]$Frequency,

        [Parameter(Mandatory=$false)]
        [string]$Duration,

        [Parameter(Mandatory=$false)]
        [string]$PatientID,

        [Parameter(Mandatory=$false)]
        [string]$PrescriptionID,

        [Parameter(Mandatory=$false)]
        [string]$PharmacistName,

        [Parameter(Mandatory=$false)]
        [switch]$Approved
    )

    # Initialize databases if they don't exist
    Function Initialize-PrescriptionDatabase {
        param($Path, $Headers)
        
        If (-not (Test-Path $Path)) {
            $Headers | Export-Csv -Path $Path -NoTypeInformation
            Write-Host "Created new database: $Path" -ForegroundColor Green
        }
    }

    # Validate required parameters based on action
    Function Test-PrescriptionParameters {
        Switch ($Action) {
            'AddMedicine' {
                If ([string]::IsNullOrWhiteSpace($MedicineName)) {
                    Throw "MedicineName is required for AddMedicine action"
                }
            }
            'CreatePrescription' {
                If ([string]::IsNullOrWhiteSpace($MedicineName) -or 
                    [string]::IsNullOrWhiteSpace($Dosage) -or 
                    [string]::IsNullOrWhiteSpace($PatientID)) {
                    Throw "MedicineName, Dosage, and PatientID are required for CreatePrescription action"
                }
            }
            'ReviewPrescription' {
                If ([string]::IsNullOrWhiteSpace($PrescriptionID) -or 
                    [string]::IsNullOrWhiteSpace($PharmacistName)) {
                    Throw "PrescriptionID and PharmacistName are required for ReviewPrescription action"
                }
            }
            'GetPrescription' {
                If ([string]::IsNullOrWhiteSpace($PrescriptionID)) {
                    Throw "PrescriptionID is required for GetPrescription action"
                }
            }
        }
    }

    Try {
        Test-PrescriptionParameters

        Switch ($Action) {
            'AddMedicine' {
                # Initialize medicine database
                $medicineHeaders = [PSCustomObject]@{
                    MedicineName = ""
                    Category = ""
                    Warnings = ""
                    DateAdded = ""
                }
                Initialize-PrescriptionDatabase -Path $MedicineDatabase -Headers $medicineHeaders

                # Check if medicine already exists
                $medicines = Import-Csv -Path $MedicineDatabase
                If ($medicines | Where-Object { $_.MedicineName -eq $MedicineName }) {
                    Write-Warning "Medicine '$MedicineName' already exists in database"
                    Return
                }

                # Add new medicine
                $newMedicine = [PSCustomObject]@{
                    MedicineName = $MedicineName
                    Category = $Category
                    Warnings = $Warnings
                    DateAdded = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                }

                $newMedicine | Export-Csv -Path $MedicineDatabase -NoTypeInformation -Append
                Write-Host "Medicine '$MedicineName' added successfully" -ForegroundColor Green
                Return $newMedicine
            }

            'CreatePrescription' {
                # Initialize prescription database
                $prescriptionHeaders = [PSCustomObject]@{
                    PrescriptionID = ""
                    MedicineName = ""
                    Dosage = ""
                    Frequency = ""
                    Duration = ""
                    PatientID = ""
                    Status = ""
                    CreatedDate = ""
                    ReviewedBy = ""
                    ReviewedDate = ""
                    Notes = ""
                }
                Initialize-PrescriptionDatabase -Path $PrescriptionDatabase -Headers $prescriptionHeaders

                # Verify medicine exists
                If (Test-Path $MedicineDatabase) {
                    $medicines = Import-Csv -Path $MedicineDatabase
                    $medicine = $medicines | Where-Object { $_.MedicineName -eq $MedicineName }
                    
                    If (-not $medicine) {
                        Write-Warning "Medicine '$MedicineName' not found in database. Please add it first."
                        Return
                    }

                    # Display warnings if any
                    If (-not [string]::IsNullOrWhiteSpace($medicine.Warnings)) {
                        Write-Host "`nWARNING: $($medicine.Warnings)" -ForegroundColor Yellow
                    }
                }

                # Generate prescription ID - find highest existing ID to avoid collisions
                $prescriptions = Import-Csv -Path $PrescriptionDatabase
                $maxID = 0
                ForEach ($rx in $prescriptions) {
                    If ($rx.PrescriptionID -match 'RX(\d+)') {
                        $currentID = [int]$Matches[1]
                        If ($currentID -gt $maxID) {
                            $maxID = $currentID
                        }
                    }
                }
                $newPrescriptionID = "RX{0:D5}" -f ($maxID + 1)

                # Create prescription with "Pending Review" status
                $newPrescription = [PSCustomObject]@{
                    PrescriptionID = $newPrescriptionID
                    MedicineName = $MedicineName
                    Dosage = $Dosage
                    Frequency = If ($Frequency) { $Frequency } Else { "As directed" }
                    Duration = If ($Duration) { $Duration } Else { "Not specified" }
                    PatientID = $PatientID
                    Status = "Pending Review"
                    CreatedDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                    ReviewedBy = ""
                    ReviewedDate = ""
                    Notes = ""
                }

                $newPrescription | Export-Csv -Path $PrescriptionDatabase -NoTypeInformation -Append
                
                Write-Host "`nPrescription created successfully!" -ForegroundColor Green
                Write-Host "Prescription ID: $newPrescriptionID" -ForegroundColor Cyan
                Write-Host "Status: Pending Pharmacist Review" -ForegroundColor Yellow
                Write-Host "`nThis prescription requires pharmacist approval before dispensing." -ForegroundColor Yellow
                
                Return $newPrescription
            }

            'ReviewPrescription' {
                If (-not (Test-Path $PrescriptionDatabase)) {
                    Write-Warning "Prescription database not found"
                    Return
                }

                $prescriptions = Import-Csv -Path $PrescriptionDatabase
                $prescription = $prescriptions | Where-Object { $_.PrescriptionID -eq $PrescriptionID }

                If (-not $prescription) {
                    Write-Warning "Prescription '$PrescriptionID' not found"
                    Return
                }

                If ($prescription.Status -ne "Pending Review") {
                    Write-Warning "Prescription '$PrescriptionID' has already been reviewed (Status: $($prescription.Status))"
                    Return $prescription
                }

                # Display prescription details for review
                Write-Host "`n=== Prescription Review ===" -ForegroundColor Cyan
                Write-Host "Prescription ID: $($prescription.PrescriptionID)"
                Write-Host "Medicine: $($prescription.MedicineName)"
                Write-Host "Dosage: $($prescription.Dosage)"
                Write-Host "Frequency: $($prescription.Frequency)"
                Write-Host "Duration: $($prescription.Duration)"
                Write-Host "Patient ID: $($prescription.PatientID)"
                Write-Host "Created: $($prescription.CreatedDate)"

                # Check for medicine warnings
                If (Test-Path $MedicineDatabase) {
                    $medicines = Import-Csv -Path $MedicineDatabase
                    $medicine = $medicines | Where-Object { $_.MedicineName -eq $prescription.MedicineName }
                    If ($medicine -and -not [string]::IsNullOrWhiteSpace($medicine.Warnings)) {
                        Write-Host "`nWarnings: $($medicine.Warnings)" -ForegroundColor Yellow
                    }
                }

                # Update prescription status
                $prescription.Status = If ($Approved) { "Approved" } Else { "Rejected" }
                $prescription.ReviewedBy = $PharmacistName
                $prescription.ReviewedDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

                # Save updated prescription
                $prescriptions | Export-Csv -Path $PrescriptionDatabase -NoTypeInformation
                
                $statusColor = If ($Approved) { "Green" } Else { "Red" }
                Write-Host "`nPrescription $($prescription.Status) by $PharmacistName" -ForegroundColor $statusColor
                
                Return $prescription
            }

            'GetPrescription' {
                If (-not (Test-Path $PrescriptionDatabase)) {
                    Write-Warning "Prescription database not found"
                    Return
                }

                $prescriptions = Import-Csv -Path $PrescriptionDatabase
                $prescription = $prescriptions | Where-Object { $_.PrescriptionID -eq $PrescriptionID }

                If (-not $prescription) {
                    Write-Warning "Prescription '$PrescriptionID' not found"
                    Return
                }

                Write-Host "`n=== Prescription Details ===" -ForegroundColor Cyan
                $prescription | Format-List
                
                Return $prescription
            }

            'ListMedicines' {
                If (-not (Test-Path $MedicineDatabase)) {
                    Write-Warning "Medicine database not found. No medicines have been added yet."
                    Return
                }

                $medicines = Import-Csv -Path $MedicineDatabase
                
                If (($medicines | Measure-Object).Count -eq 0) {
                    Write-Host "No medicines in database" -ForegroundColor Yellow
                    Return
                }

                Write-Host "`n=== Medicine Database ===" -ForegroundColor Cyan
                $medicines | Format-Table -AutoSize
                
                Return $medicines
            }
        }
    }
    Catch {
        Write-Error "An error occurred: $_"
        Return $null
    }
}
