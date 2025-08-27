module load imagemagick/7.1.1

for page in {37..43}; do
    echo "Processing page $page"
    echo "File /project/rcc/hyadav/CuReD/data/CAD/split_pages/page-$(printf "%03d" $page).pdf"
    magick -density 900 -quality 100 -colorspace Gray -background white -type Grayscale -depth 8 /project/rcc/hyadav/CuReD/data/CAD/split_pages/page-$(printf "%03d" $page).pdf /project/rcc/hyadav/CuReD/data/CAD/split_pages/page-$(printf "%03d" $page).png
done