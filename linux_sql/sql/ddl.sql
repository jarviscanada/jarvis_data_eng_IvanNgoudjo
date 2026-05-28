-- 1. Switch to host_agent database
\c host_agent;

-- 2. Create host_info table if not exist
CREATE TABLE IF NOT EXISTS public.host_info 
  ( 
     id               SERIAL NOT NULL, 
     hostname         VARCHAR NOT NULL, 
     cpu_number       INT2 NOT NULL, 
     cpu_architecture VARCHAR NOT NULL, 
     cpu_model        VARCHAR NOT NULL, 
     cpu_mhz          FLOAT8 NOT NULL, 
     l2_cache         INT4 NOT NULL, 
     "timestamp"      TIMESTAMP NOT NULL, 
     total_mem        INT4 NOT NULL, 
     CONSTRAINT host_info_pk PRIMARY KEY (id), 
     CONSTRAINT host_info_un UNIQUE (hostname) 
  );

-- 3. Create host_usage table if not exist
CREATE TABLE IF NOT EXISTS public.host_usage 
  ( 
     "timestamp"    TIMESTAMP NOT NULL, 
     host_id        SERIAL NOT NULL, 
     memory_free    INT4 NOT NULL, 
     cpu_idle       INT2 NOT NULL, 
     cpu_kernel     INT2 NOT NULL, 
     disk_io        INT4 NOT NULL, 
     disk_available INT4 NOT NULL, 
     CONSTRAINT host_usage_host_info_fk FOREIGN KEY (host_id) REFERENCES public.host_info(id)
  );
