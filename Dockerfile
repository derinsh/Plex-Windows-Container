# Host Windows version
ARG winver=latest

# Host architecture
ARG arch=x86_64

FROM mcr.microsoft.com/windows:$winver

# Copy build directory to image
COPY PlexSetup C:\\PlexSetup

# Set working directory
WORKDIR C:\\PlexSetup

# Install Plex
## 64-bit installer uses /verysilent instead of /quiet
RUN if exist Setup64.exe (Setup64.exe /verysilent) else (Setup.exe /quiet)
RUN reg import Config.reg

# Cleanup
RUN If EXIST Setup64.exe (del /F /Q Setup64.exe)
RUN If EXIST Setup.exe (del /F /Q Setup.exe)
RUN del /F /Q Config.reg

# Expose port and bind a storage volume C:\Plex for Plex Server database
EXPOSE 32400/tcp
VOLUME C:\\Plex

# For quick adjustment copy Run.cmd as a last step
COPY Run.cmd C:\\PlexSetup\\Run.cmd

# Define the entrypoint
CMD Run.cmd
