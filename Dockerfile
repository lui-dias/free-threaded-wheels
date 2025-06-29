# Start from a minimal Debian base image
FROM amd64/ubuntu:latest

# Copy the 'uv' and 'uvx' executables from the official 'uv' Docker image.
# This ensures 'uv' is aear
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Update the package lists, upgrade existing packages, and install
# essential tools:
# - git: Needed to clone the opencv-python repository.
# - build-essential: Provides compilers and other tools necessary to build
#   Python packages that include C/C++ extensions, which opencv-python does.
RUN apt update && apt upgrade -y && apt install -y git build-essential \
    libtiff5-dev libjpeg8-dev libopenjp2-7-dev zlib1g-dev libfreetype6-dev \
    liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python3-tk libharfbuzz-dev \
    libfribidi-dev libxcb1-dev libjpeg62-turbo-dev

# Install a specific Python version using 'uv'.
# Using Python 3.14t (assuming this is a valid uv specifier for 3.14, usually just 3.14)
# 'uv' manages isolated Python environments.
RUN uv python install 3.14

# Clone the Pillow repository into /opt/pillow.
# --recursive: Ensures all necessary submodules are also cloned (though Pillow might not have many).
# --depth 1: Performs a shallow clone, getting only the latest commit,
#            which reduces the image size and clone time.
RUN git clone --recursive --depth 1 https://github.com/python-pillow/Pillow /opt/pillow

# Change the working directory to the cloned repository.
# All subsequent commands will be executed from this directory.
WORKDIR /opt/pillow

# Build the Pillow wheel.
# The wheel will be generated in the 'dist/' directory relative to the WORKDIR.
# $(uv python find 3.14): Dynamically finds the path to the Python executable installed by uv.
# -m pip wheel .: Uses the installed pip to build the wheel from the current directory.
# -v: Enables verbose output during the build process.
RUN $(uv python find 3.14) -m pip wheel . -v