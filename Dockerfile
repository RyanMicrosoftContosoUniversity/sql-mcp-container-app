FROM mcr.microsoft.com/azure-databases/data-api-builder:2.0.12

# dd JSON parsing for startup smoke tests and remove package caches
RUN tdnf install -y jq && tdnf clean all

# Include the DAB configuration; database credentials are supplied at runtime
COPY dab-config.json /App/dab-config.json

# Include the startup smoke test script
COPY scripts/smoke-test.sh /App/scripts/smoke-test.sh
COPY scripts/entrypoint.sh /App/scripts/entrypoint.sh

RUN /bin/bash -n /App/scripts/smoke-test.sh \
    && /bin/bash -n /App/scripts/entrypoint.sh

    
ENTRYPOINT ["/bin/bash", "/App/scripts/entrypoint.sh"]