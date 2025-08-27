module load python/miniforge-25.3.0
module load gcc/13.2.0

source activate kraken_env

# Set library path
export LD_LIBRARY_PATH=/project/rcc/hyadav/lipvips-8.18.0/lib64:$LD_LIBRARY_PATH

# Set pkg-config path (you already have this)
export PKG_CONFIG_PATH=/project/rcc/hyadav/lipvips-8.18.0/lib64/pkgconfig:$PKG_CONFIG_PATH

# Test Python import
python -c "import pyvips; print('pyvips loaded successfully')"

kraken -I /project/rcc/hyadav/CuReD/data/CAD/split_pages/png_tests/output-000.png -o /project/rcc/hyadav/CuReD/data/CAD/predictions/ocr.txt binarize segment ocr -m ../models/latest.mlmodel

# magick -density 600 page-034.pdf test-600.png
# magick -density 900 page-034.pdf test-900.png
# magick -density 1200 page-034.pdf test-1200.png

# magick -density 900 -quality 100 -colorspace Gray -background white -type Grayscale -depth 8 page-034.pdf output-%03d.png
