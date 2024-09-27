# Use the official Microsoft SQL Server Express image from the Docker Hub
FROM mcr.microsoft.com/mssql/server:2022-latest

# Set environment variables
ENV SA_PASSWORD=Strong&Password=94210
ENV ACCEPT_EULA=Y

# Expose the SQL Server port
EXPOSE 1433

# Run SQL Server
CMD ["/opt/mssql/bin/sqlservr"]