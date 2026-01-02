<#
.SYNOPSIS
    Demo script for Manage-Prescription.ps1

.DESCRIPTION
    Demonstrates the full workflow of the automated prescription management system:
    1. Adding medicines to the database
    2. Creating prescriptions that require review
    3. Pharmacist reviewing and approving/rejecting prescriptions
    4. Retrieving prescription details

.EXAMPLE
    .\Demo-Prescription.ps1
    Run the full demo workflow
#>

# Import the prescription management module
. "$PSScriptRoot\Manage-Prescription.ps1"

Write-Host "`n==============================================================" -ForegroundColor Cyan
Write-Host "  Automated Prescription Management System - Demo" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan

Write-Host "`n--- Step 1: Setting up Medicine Database ---" -ForegroundColor Yellow
Write-Host "Adding common medicines with their warnings...`n"

# Add some common medicines
Manage-Prescription -Action AddMedicine -MedicineName "Amoxicillin" -Category "Antibiotic" -Warnings "Check for penicillin allergy. May cause allergic reactions."
Manage-Prescription -Action AddMedicine -MedicineName "Ibuprofen" -Category "Pain Relief/Anti-inflammatory" -Warnings "Take with food. Avoid if history of stomach ulcers."
Manage-Prescription -Action AddMedicine -MedicineName "Lisinopril" -Category "Blood Pressure" -Warnings "Monitor blood pressure regularly. May cause dizziness."
Manage-Prescription -Action AddMedicine -MedicineName "Metformin" -Category "Diabetes" -Warnings "Take with meals. Monitor blood sugar levels."

Write-Host "`n--- Step 2: Viewing Medicine Database ---" -ForegroundColor Yellow
Manage-Prescription -Action ListMedicines

Write-Host "`n--- Step 3: Creating Prescriptions (Requires Pharmacist Review) ---" -ForegroundColor Yellow
Write-Host "Creating prescriptions for different patients...`n"

# Create prescription 1
Write-Host "`nPrescription for Patient P12345:" -ForegroundColor Cyan
Manage-Prescription -Action CreatePrescription -MedicineName "Amoxicillin" -Dosage "500mg" -Frequency "Three times daily" -Duration "7 days" -PatientID "P12345"

# Create prescription 2
Write-Host "`n`nPrescription for Patient P67890:" -ForegroundColor Cyan
Manage-Prescription -Action CreatePrescription -MedicineName "Ibuprofen" -Dosage "400mg" -Frequency "Twice daily with food" -Duration "5 days" -PatientID "P67890"

# Create prescription 3
Write-Host "`n`nPrescription for Patient P11111:" -ForegroundColor Cyan
Manage-Prescription -Action CreatePrescription -MedicineName "Lisinopril" -Dosage "10mg" -Frequency "Once daily in the morning" -Duration "30 days" -PatientID "P11111"

Write-Host "`n`n--- Step 4: Pharmacist Review Workflow ---" -ForegroundColor Yellow
Write-Host "Pharmacist reviewing pending prescriptions...`n"

# Pharmacist reviews and approves prescription 1
Write-Host "`nPharmacist Dr. Smith reviewing RX00001:" -ForegroundColor Cyan
Manage-Prescription -Action ReviewPrescription -PrescriptionID "RX00001" -PharmacistName "Dr. Smith" -Approved

# Pharmacist reviews and rejects prescription 2 (for demo purposes)
Write-Host "`n`nPharmacist Dr. Johnson reviewing RX00002:" -ForegroundColor Cyan
Manage-Prescription -Action ReviewPrescription -PrescriptionID "RX00002" -PharmacistName "Dr. Johnson"

# Pharmacist reviews and approves prescription 3
Write-Host "`n`nPharmacist Dr. Smith reviewing RX00003:" -ForegroundColor Cyan
Manage-Prescription -Action ReviewPrescription -PrescriptionID "RX00003" -PharmacistName "Dr. Smith" -Approved

Write-Host "`n`n--- Step 5: Retrieving Prescription Details ---" -ForegroundColor Yellow
Write-Host "Checking status of approved prescription...`n"

Manage-Prescription -Action GetPrescription -PrescriptionID "RX00001"

Write-Host "`n==============================================================" -ForegroundColor Cyan
Write-Host "  Demo Complete!" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan

Write-Host "`nKey Features Demonstrated:" -ForegroundColor Green
Write-Host "  ✓ Medicine database with safety warnings" -ForegroundColor Green
Write-Host "  ✓ Automatic warning display during prescription creation" -ForegroundColor Green
Write-Host "  ✓ Mandatory pharmacist review for all prescriptions" -ForegroundColor Green
Write-Host "  ✓ Approval and rejection workflow" -ForegroundColor Green
Write-Host "  ✓ Complete audit trail with dates and reviewer names" -ForegroundColor Green
Write-Host "`nThis ensures pharmacist oversight is maintained while" -ForegroundColor Yellow
Write-Host "automating routine prescription management tasks.`n" -ForegroundColor Yellow
