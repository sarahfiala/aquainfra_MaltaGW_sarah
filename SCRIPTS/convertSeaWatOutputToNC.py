#!/usr/bin/env python3

import argparse
import os
import numpy as np
import xarray as xr
import flopy
import flopy.utils.binaryfile as bf

def extract_coordinates(dis_path):
    model_ws = os.path.dirname(dis_path)
    dis_file = os.path.basename(dis_path)

    # Load model (we need to wrap in a dummy MODFLOW model for .dis to parse)
    modelname = os.path.splitext(dis_file)[0]
    mf = flopy.modflow.Modflow(modelname=modelname, model_ws=model_ws)

    #set the current working directory
    os.chdir (model_ws);


    #load the model
    dis = flopy.modflow.ModflowDis.load(dis_file, model=mf)

    nlay, nrow, ncol = dis.nlay, dis.nrow, dis.ncol

    # Compute X and Y coordinates manually
    delr = dis.delr.array  # width of each column (ncol,)
    delc = dis.delc.array  # height of each row (nrow,)

    x = np.cumsum(delr) - 0.5 * delr
    y = np.cumsum(delc[::-1]) - 0.5 * delc[::-1]  # north-up orientation
    z = np.arange(nlay)

    print(f"Extracted grid: {nlay} layers, {nrow} rows, {ncol} cols")
    return x, y, z

def load_ucn(ucn_path):
    ucn = bf.UcnFile(ucn_path)
    times = ucn.get_times()
    conc_data = [ucn.get_data(totim=t) for t in times]
    conc_array = np.array(conc_data)  # shape: (ntime, nlay, nrow, ncol)
    print(f"✅ Loaded UCN file with shape: {conc_array.shape} and {len(times)} time steps")
    return conc_array, times

def save_to_netcdf(conc_array, times, x, y, z, output_path):
    ds = xr.Dataset(
        {
            "concentration": (["time", "layer", "y", "x"], conc_array)
        },
        coords={
            "time": times,
            "layer": z,
            "y": y,
            "x": x
        }
    )

    ds["concentration"].attrs["units"] = "mg/L"
    ds.attrs["title"] = "SEAWAT Concentration Output"
    ds.attrs["description"] = "Converted from binary UCN using flopy + xarray"

    ds.to_netcdf(output_path)
    print(f"✅ NetCDF saved to: {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Convert UCN and DIS to NetCDF.")
    parser.add_argument("--ucn", required=True, help="Path to .UCN concentration file")
    parser.add_argument("--dis", required=True, help="Path to .DIS discretization file")
    parser.add_argument("--output", default="output_concentration.nc", help="Output NetCDF file")

    args = parser.parse_args()

    if not os.path.isfile(args.ucn):
        print(f"❌ UCN file not found: {args.ucn}")
        return

    if not os.path.isfile(args.dis):
        print(f"❌ DIS file not found: {args.dis}")
        return

    x, y, z = extract_coordinates(args.dis)
    conc_array, times = load_ucn(args.ucn)
    save_to_netcdf(conc_array, times, x, y, z, args.output)

if __name__ == "__main__":
    main()

