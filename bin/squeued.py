#!/usr/bin/env python
# -*- coding: utf-8 -*-
import argparse
import datetime
import getpass
import io
import logging.handlers
import os
import shelve
import subprocess
import sys
import time

import pandas as pd


def squeue():
    rslt = subprocess.run(
        ["squeue", "-o", "%all"],
        capture_output=True,
        check=True,
    )
    df = pd.read_csv(
        io.StringIO(
            rslt.stdout.decode("utf-8")
        ),
        sep="|"
    )
    df = df.drop("Unnamed: 18", axis="columns")
    df["LAST_SEEN"] = datetime.datetime.now().isoformat()
    df["COMPLETE"] = False
    return df.to_dict("records")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-o", "--output", default=f"/gpfs/scratch/{getpass.getuser()}/squeued.shelf")
    args = parser.parse_args()
    # Intialize logging.
    scriptname = os.path.basename(sys.argv[0]).replace(".py", "")
    logpath = time.strftime(
        f"/gpfs/scratch/{getpass.getuser()}/logs/{scriptname}.%Y%m%d.%H%M%S.log"
    )
    os.makedirs(os.path.dirname(logpath), exist_ok=True)
    logging.basicConfig(
        format="[%(asctime)s] [%(levelname)8s] --- %(message)s (%(filename)s:%(lineno)s)",
        datefmt="%Y-%m-%d %H:%M:%S",
        level=logging.INFO,
        handlers=[logging.StreamHandler(), logging.FileHandler(logpath)],
    )
    log = logging.getLogger(__name__)
    log.info("Initialized logging: %s", logpath)
    # Start the daemon.
    log.info("Loading shelf: %s", args.output)
    with shelve.open(args.output) as db:
        while True:
            jids = set(db.keys())
            jobs = squeue()
            for job in jobs:
                db[str(job["JOBID"])] = job
            running_jids = {str(job["JOBID"]) for job in jobs}
            # Log new jobids.
            new_jids = running_jids - jids
            if new_jids:
                log.info("Discovered %s new jobs: %s", len(new_jids), " ".join(new_jids))
                log.info("Tracking %s jobs in total.", len(db))
            # Log jobids that no longer appear in squeue.
            done_jids = {jid for jid in (jids - running_jids) if db[jid]["COMPLETE"] == False}
            for jid in done_jids:
                tmp = db[jid]
                tmp["COMPLETE"] = True
                db[jid] = tmp  # To ensure the shelf flushes.
            if done_jids:
                log.info("Marked %s jobs complete: %s", len(done_jids), " ".join(done_jids))


if __name__ == "__main__":
    main()
