# aquainfra_MaltaGW

## 🛠 Runtime Parameters

This container accepts the following command-line arguments at runtime:

| Parameter            | Description                                                                | Default Value             |
|---------------------|----------------------------------------------------------------------------|---------------------------|
| `--user_sealevels`  | List of sea level values (in metres) to simulate.                          | `[-2.675, -1.3375, 0.0]`  |
| `--sealevel_int`    | Interval duration in years between each sea level in the list.             | `500`                     |
| `--user_recharge`   | Recharge value used in the simulation.                                     | `0.00125`                 |

### 📌 Example Usage

```bash
docker run my-image \
  --user_sealevels "[-3.0, -2.0, -1.0]" \
  --sealevel_int 250 \
  --user_recharge 0.002


