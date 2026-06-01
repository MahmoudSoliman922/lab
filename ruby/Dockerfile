FROM ruby:3.1

# python3 + pip   → Jupyter
# libzmq3-dev     → ZMQ (required by cztop / IRuby)
# libczmq-dev     → CZMQ (required by cztop)
# librdkafka-dev  → speeds up rdkafka native build (Karafka dep)
# cmake           → sometimes needed by rdkafka's build system
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 python3-pip python3-venv \
      libzmq3-dev libczmq-dev \
      librdkafka-dev cmake \
      sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Install Jupyter into a venv to avoid Debian Bookworm's system-pip restriction
RUN python3 -m venv /opt/jupyter \
    && /opt/jupyter/bin/pip install --no-cache-dir jupyterlab

ENV PATH="/opt/jupyter/bin:$PATH"

WORKDIR /lab/ruby

COPY Gemfile .
RUN bundle install

# Register the Ruby kernel so Jupyter can see it.
# Using `bundle exec` ensures iruby runs against the same gems it will use
# at notebook runtime, avoiding version mismatches.
RUN bundle exec iruby register --force

EXPOSE 8888

CMD ["jupyter", "lab", \
     "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", \
     "--ServerApp.token=''", "--ServerApp.password=''"]
