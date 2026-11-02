param(
    [string]$OutputDir = "sample_receipts"
)

Add-Type -AssemblyName System.Drawing

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

function Generate-Receipt {
    param(
        [string]$FileName,
        [string]$StoreName,
        [string]$StoreBranch,
        [string]$StoreAddress,
        [string]$Phone,
        [string]$CategoryLabel,
        [string]$ReceiptNo,
        [string]$DateTimeStr,
        [string]$Cashier,
        [array]$Items,
        [double]$Subtotal,
        [double]$Tax,
        [double]$Total,
        [string]$PaymentMethod,
        [string]$FooterNote
    )

    $width = 650
    $itemCount = $Items.Count
    $height = 780 + ($itemCount * 32)

    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    # Paper Background
    $paperBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(253, 253, 254))
    $g.FillRectangle($paperBrush, 0, 0, $width, $height)

    # Outer subtle paper border
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 224, 230), 2)
    $g.DrawRectangle($borderPen, 6, 6, $width - 12, $height - 12)

    # Fonts
    $fontHeader = New-Object System.Drawing.Font("Lucida Console", 17, [System.Drawing.FontStyle]::Bold)
    $fontSub = New-Object System.Drawing.Font("Lucida Console", 9.5, [System.Drawing.FontStyle]::Regular)
    $fontBody = New-Object System.Drawing.Font("Lucida Console", 11, [System.Drawing.FontStyle]::Regular)
    $fontBodyBold = New-Object System.Drawing.Font("Lucida Console", 11, [System.Drawing.FontStyle]::Bold)
    $fontTotal = New-Object System.Drawing.Font("Lucida Console", 19, [System.Drawing.FontStyle]::Bold)
    $fontSmall = New-Object System.Drawing.Font("Lucida Console", 8.5, [System.Drawing.FontStyle]::Regular)

    # Brushes
    $inkBlack = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(20, 24, 27))
    $inkGray = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(90, 95, 105))
    $highlightBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 243, 246))

    # String Formats
    $centerFmt = New-Object System.Drawing.StringFormat
    $centerFmt.Alignment = [System.Drawing.StringAlignment]::Center

    $leftFmt = New-Object System.Drawing.StringFormat
    $leftFmt.Alignment = [System.Drawing.StringAlignment]::Near

    $rightFmt = New-Object System.Drawing.StringFormat
    $rightFmt.Alignment = [System.Drawing.StringAlignment]::Far

    # Pen for dashed separators
    $dashPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(160, 165, 175), 1.5)
    $dashPen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
    $doublePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(50, 55, 65), 2)

    $y = 35

    # Top Star Motif & Store Header
    $g.DrawString("*** $StoreName ***", $fontHeader, $inkBlack, [float]($width / 2), $y, $centerFmt)
    $y += 32
    $g.DrawString($StoreBranch, $fontSub, $inkGray, [float]($width / 2), $y, $centerFmt)
    $y += 18
    $g.DrawString($StoreAddress, $fontSub, $inkGray, [float]($width / 2), $y, $centerFmt)
    $y += 18
    $g.DrawString("TEL: $Phone  *  TAX ID: 94-882194-US", $fontSub, $inkGray, [float]($width / 2), $y, $centerFmt)
    $y += 28

    # Dashed divider
    $g.DrawLine($dashPen, 40, $y, $width - 40, $y)
    $y += 14

    # Metadata lines (Receipt No, Date, Cashier, Category)
    $g.DrawString("RECEIPT NO : $ReceiptNo", $fontSub, $inkBlack, 40, $y, $leftFmt)
    $g.DrawString("CASHIER: $Cashier", $fontSub, $inkBlack, $width - 40, $y, $rightFmt)
    $y += 20
    $g.DrawString("DATE & TIME: $DateTimeStr", $fontSub, $inkBlack, 40, $y, $leftFmt)
    $g.DrawString("CATEGORY: $CategoryLabel", $fontBodyBold, $inkBlack, $width - 40, $y, $rightFmt)
    $y += 26

    # Dashed divider
    $g.DrawLine($dashPen, 40, $y, $width - 40, $y)
    $y += 14

    # Table Column Headers
    $g.DrawString("ITEM DESCRIPTION", $fontBodyBold, $inkBlack, 40, $y, $leftFmt)
    $g.DrawString("QTY", $fontBodyBold, $inkBlack, 410, $y, $centerFmt)
    $g.DrawString("AMOUNT", $fontBodyBold, $inkBlack, $width - 40, $y, $rightFmt)
    $y += 24
    $g.DrawLine($dashPen, 40, $y, $width - 40, $y)
    $y += 16

    # Item rows
    foreach ($item in $Items) {
        $name = $item.Name
        $qty = $item.Qty
        $price = "{0:N2}" -f $item.Price

        $g.DrawString($name, $fontBody, $inkBlack, 40, $y, $leftFmt)
        $g.DrawString("$qty", $fontBody, $inkBlack, 410, $y, $centerFmt)
        $g.DrawString($price, $fontBody, $inkBlack, $width - 40, $y, $rightFmt)
        $y += 30
    }

    $y += 8
    # Divider before totals
    $g.DrawLine($dashPen, 40, $y, $width - 40, $y)
    $y += 16

    # Subtotal & Tax
    $subtotalStr = "{0:N2}" -f $Subtotal
    $taxStr = "{0:N2}" -f $Tax
    $g.DrawString("SUBTOTAL", $fontBody, $inkGray, 40, $y, $leftFmt)
    $g.DrawString($subtotalStr, $fontBody, $inkBlack, $width - 40, $y, $rightFmt)
    $y += 24

    $g.DrawString("TAX / GST (0.00%)", $fontBody, $inkGray, 40, $y, $leftFmt)
    $g.DrawString($taxStr, $fontBody, $inkBlack, $width - 40, $y, $rightFmt)
    $y += 30

    # Highlight Total Box
    $g.FillRectangle($highlightBrush, 36, $y - 6, $width - 72, 54)
    $g.DrawRectangle($doublePen, 36, $y - 6, $width - 72, 54)

    $totalStr = "{0:N2}" -f $Total
    $g.DrawString("TOTAL AMOUNT", $fontTotal, $inkBlack, 46, $y + 6, $leftFmt)
    $g.DrawString("$totalStr", $fontTotal, $inkBlack, $width - 46, $y + 6, $rightFmt)
    $y += 66

    # Payment Info
    $g.DrawString("PAYMENT METHOD : $PaymentMethod", $fontSub, $inkBlack, 40, $y, $leftFmt)
    $g.DrawString("STATUS: APPROVED", $fontSub, $inkBlack, $width - 40, $y, $rightFmt)
    $y += 20
    $g.DrawString("AUTH CODE      : #AUTH-991048", $fontSub, $inkGray, 40, $y, $leftFmt)
    $g.DrawString("PENNYPAL VERIFIED", $fontSub, $inkGray, $width - 40, $y, $rightFmt)
    $y += 28

    $g.DrawLine($dashPen, 40, $y, $width - 40, $y)
    $y += 18

    # Realistic Barcode
    $barcodeX = 80
    $barcodeWidth = $width - 160
    $barcodeHeight = 44
    $rng = New-Object System.Random(42)
    $curX = $barcodeX
    while ($curX -lt ($barcodeX + $barcodeWidth)) {
        $barW = $rng.Next(1, 4)
        $gapW = $rng.Next(1, 3)
        $g.FillRectangle($inkBlack, $curX, $y, $barW, $barcodeHeight)
        $curX += ($barW + $gapW)
    }
    $y += $barcodeHeight + 6

    # Barcode number
    $g.DrawString("* $ReceiptNo *", $fontSmall, $inkGray, [float]($width / 2), $y, $centerFmt)
    $y += 22

    # Footer Notes
    $g.DrawString("*** THANK YOU FOR YOUR VISIT ***", $fontBodyBold, $inkBlack, [float]($width / 2), $y, $centerFmt)
    $y += 20
    $g.DrawString($FooterNote, $fontSub, $inkGray, [float]($width / 2), $y, $centerFmt)
    $y += 18
    $g.DrawString("Optimized for PennyPal AI Receipt OCR Scanner", $fontSmall, $inkGray, [float]($width / 2), $y, $centerFmt)

    # Save PNG and JPG
    $pngPath = Join-Path $OutputDir "$FileName.png"
    $jpgPath = Join-Path $OutputDir "$FileName.jpg"

    $bmp.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Save high quality JPEG
    $jpgEncoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]95)
    $bmp.Save($jpgPath, $jpgEncoder, $encoderParams)

    $g.Dispose()
    $bmp.Dispose()

    Write-Host "Created: $pngPath and $jpgPath"
}

# 1. Starbucks Coffee (Primary viva demo - Category: Food, Total: 450.00)
Generate-Receipt `
    -FileName "starbucks_coffee_450" `
    -StoreName "STARBUCKS COFFEE" `
    -StoreBranch "Campus Center Branch #1042" `
    -StoreAddress "University Avenue, Student Commons" `
    -Phone "(555) 019-2834" `
    -CategoryLabel "Food" `
    -ReceiptNo "RCP-2026-8841" `
    -DateTimeStr "2026-11-02 10:30 AM" `
    -Cashier "Sarah M." `
    -Items @(
        @{ Name = "Caffe Latte Grande"; Qty = 1; Price = 180.00 },
        @{ Name = "Caramel Macchiato"; Qty = 1; Price = 220.00 },
        @{ Name = "Butter Croissant"; Qty = 1; Price = 50.00 }
    ) `
    -Subtotal 450.00 `
    -Tax 0.00 `
    -Total 450.00 `
    -PaymentMethod "CARD / APPLE PAY" `
    -FooterNote "Keep receipt for your PennyPal expense budget"

# 2. Campus Cafe & Bakery (Category: Food, Total: 320.00)
Generate-Receipt `
    -FileName "campus_cafe_320" `
    -StoreName "CAMPUS CAFE & BAKERY" `
    -StoreBranch "Student Union Food Court" `
    -StoreAddress "Aptech Campus, Block 5" `
    -Phone "(555) 018-7741" `
    -CategoryLabel "Food" `
    -ReceiptNo "CAFE-2026-4419" `
    -DateTimeStr "2026-11-02 01:15 PM" `
    -Cashier "Ali Raza" `
    -Items @(
        @{ Name = "Club Sandwich Special"; Qty = 1; Price = 200.00 },
        @{ Name = "Fresh Mint Lemonade"; Qty = 1; Price = 120.00 }
    ) `
    -Subtotal 320.00 `
    -Tax 0.00 `
    -Total 320.00 `
    -PaymentMethod "CASH" `
    -FooterNote "Fresh food daily for students"

# 3. University Bookstore (Category: Education, Total: 950.00)
Generate-Receipt `
    -FileName "university_bookstore_950" `
    -StoreName "UNIVERSITY BOOKSTORE" `
    -StoreAddress "Academic Building B, Ground Floor" `
    -StoreBranch "Central Campus Mart" `
    -Phone "(555) 012-9988" `
    -CategoryLabel "Education" `
    -ReceiptNo "BK-2026-7712" `
    -DateTimeStr "2026-11-02 11:45 AM" `
    -Cashier "Tariq K." `
    -Items @(
        @{ Name = "Data Structures Handbook"; Qty = 1; Price = 650.00 },
        @{ Name = "College Spiral Notebook 2x"; Qty = 2; Price = 200.00 },
        @{ Name = "Fine Gel Pen Set (Black)"; Qty = 1; Price = 100.00 }
    ) `
    -Subtotal 950.00 `
    -Tax 0.00 `
    -Total 950.00 `
    -PaymentMethod "DEBIT CARD" `
    -FooterNote "Educational stationery & course handbooks"

# 4. McDonald's (Category: Food, Total: 650.00)
Generate-Receipt `
    -FileName "mcdonalds_burger_650" `
    -StoreName "MCDONALD'S RESTAURANT" `
    -StoreBranch "Drive-Thru Store #412" `
    -StoreAddress "North Nazimabad Main Blvd" `
    -Phone "(555) 014-6321" `
    -CategoryLabel "Food" `
    -ReceiptNo "MCD-2026-3021" `
    -DateTimeStr "2026-11-02 02:40 PM" `
    -Cashier "Zainab F." `
    -Items @(
        @{ Name = "Big Mac Value Meal"; Qty = 1; Price = 450.00 },
        @{ Name = "Oreo McFlurry Regular"; Qty = 1; Price = 200.00 }
    ) `
    -Subtotal 650.00 `
    -Tax 0.00 `
    -Total 650.00 `
    -PaymentMethod "MOBILE WALLET" `
    -FooterNote "Thank you for dining with McDonald's"

# 5. Grocery Mart (Category: Food / Shopping, Total: 1450.00)
Generate-Receipt `
    -FileName "grocery_mart_1450" `
    -StoreName "GROCERY SUPERMART" `
    -StoreBranch "Campus Express Outlet" `
    -StoreAddress "Commercial Avenue, Shop #12" `
    -Phone "(555) 015-8833" `
    -CategoryLabel "Food" `
    -ReceiptNo "MART-2026-9923" `
    -DateTimeStr "2026-11-02 04:10 PM" `
    -Cashier "Hassan M." `
    -Items @(
        @{ Name = "Fresh Dairy Milk 2L"; Qty = 1; Price = 350.00 },
        @{ Name = "Whole Grain Bread Loaf"; Qty = 1; Price = 220.00 },
        @{ Name = "Organic Eggs 12-Pack"; Qty = 1; Price = 380.00 },
        @{ Name = "Breakfast Cereal Family"; Qty = 1; Price = 500.00 }
    ) `
    -Subtotal 1450.00 `
    -Tax 0.00 `
    -Total 1450.00 `
    -PaymentMethod "CARD" `
    -FooterNote "Daily student grocery essentials"

# 6. Shell Fuel Station (Category: Transport, Total: 1500.00)
Generate-Receipt `
    -FileName "shell_fuel_1500" `
    -StoreName "SHELL FUEL STATION" `
    -StoreBranch "Express Service Station #88" `
    -StoreAddress "Highway Bypass, Pump #04" `
    -Phone "(555) 016-4422" `
    -CategoryLabel "Transport" `
    -ReceiptNo "SHL-2026-5520" `
    -DateTimeStr "2026-11-02 06:20 PM" `
    -Cashier "Ahmed K." `
    -Items @(
        @{ Name = "Unleaded Super Petrol"; Qty = 1; Price = 1500.00 }
    ) `
    -Subtotal 1500.00 `
    -Tax 0.00 `
    -Total 1500.00 `
    -PaymentMethod "CASH" `
    -FooterNote "Have a safe student commute"

