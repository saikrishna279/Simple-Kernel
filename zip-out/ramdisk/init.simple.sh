#!/vendor/bin/sh

setSimpleConfig() {

sleep 10

# Set the default IRQ affinity to the silver cluster. When a
# CPU is isolated/hotplugged, the IRQ affinity is adjusted
# to one of the CPU from the default IRQ affinity mask.
echo f > /proc/irq/default_smp_affinity

# IO block tweaks for better system performance;
for i in /sys/block/*/queue; do
  echo 0 > $i/add_random;
  echo 0 > $i/iostats;
  echo 0 > $i/nomerges;
  echo 32 > $i/nr_requests;
  echo 128 > $i/read_ahead_kb;
  echo 0 > $i/rotational;
  echo 1 > $i/rq_affinity;
  echo "cfq" > $i/scheduler;
done;

#Tweak cfq IO scheduler for less latency
for i in /sys/block/*/queue/iosched; do
  echo 4 > $i/quantum;
  echo 80 > $i/fifo_expire_sync;
  echo 330 > $i/fifo_expire_async;
  echo 12582912 > $i/back_seek_max;
  echo 1 > $i/back_seek_penalty;
  echo 60 > $i/slice_sync;
  echo 50 > $i/slice_async;
  echo 2 > $i/slice_async_rq;
  echo 0 > $i/slice_idle;
  echo 0 > $i/group_idle;
  echo 1 > $i/low_latency;
  echo 300 > $i/target_latency;
done;

# Disable CAF task placement for Big Cores
echo 0 > /proc/sys/kernel/sched_walt_rotate_big_tasks

# Disable Boost_No_Override
echo > 0 /dev/stune/foreground/schedtune.sched_boost_no_override
echo > 0 /dev/stune/top-app/schedtune.sched_boost_no_override

# Set default schedTune value for foreground/top-app
echo 1 > /dev/stune/foreground/schedtune.prefer_idle 
echo 1 > /dev/stune/top-app/schedtune.prefer_idle

# Setup EAS cpusets values for better load balancing
echo "0-7" > /dev/cpuset/top-app/cpus 

# Since we are not using core rotator, lets load balance
echo "0-3,6-7" > /dev/cpuset/foreground/cpus
echo "0-1" > /dev/cpuset/background/cpus
echo "0-3" > /dev/cpuset/system-background/cpus 

# Manually force all of the kernel tasks to be applied upon the low power cores / cluster for power saving reasons;
echo "0-3" > /dev/cpuset/kernel/cpus

# For better screen off idle
echo "0-3" > /dev/cpuset/restricted/cpus 

# Enable scheduler core_ctl
echo 1 > /sys/devices/system/cpu/cpu0/core_ctl/enable
echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/enable

# Increase how much CPU bandwidth (CPU time) realtime scheduling processes are given
echo "980000" > /proc/sys/kernel/sched_rt_runtime_us

# configure governor settings for little cluster
echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
echo 1209600 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/hispeed_freq
echo 1 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/pl
echo 500 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/up_rate_limit_us
echo 20000 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/down_rate_limit_us 
	
# configure governor settings for big cluster
echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor
echo 1574400 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/hispeed_freq
echo 1 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/pl
echo 500 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/up_rate_limit_us
echo 20000 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/down_rate_limit_us 

# Disable in-kernel sched statistics for reduced overhead;
echo "0" > /proc/sys/kernel/sched_schedstats

# Disable Gentle Fair Sleepers for a smoother UI;
echo "NO_GENTLE_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features

#Enable suspend to idle mode to reduce latency during suspend/resume
echo "s2idle" > /sys/power/mem_sleep

# Toggle Sched Features
echo "NO_FBT_STRICT_ORDER" > /sys/kernel/debug/sched_features

# Reduce swappiness: 100 -> 85 (since December update)
# This reduces kswapd0 CPU usage, leading to
# better performance and battery due to less CPU time used
echo 65 > /proc/sys/vm/swappiness

# Disable a few minor and overall pretty useless modules for slightly better battery life & system wide performance;
echo "Y" > /sys/module/bluetooth/parameters/disable_ertm
echo "Y" > /sys/module/bluetooth/parameters/disable_esco

# Use the deepest CPU idle state for a few additional power savings if your kernel of choice now supports it;
echo "1" > /sys/devices/system/cpu/cpuidle/use_deepest_state

# Enable display / screen panel power saving features;
echo "Y" > /sys/kernel/debug/dsi_ss_ea8074_notch_fhd_cmd_display/dsi-phy-0_allow_phy_power_off
echo "Y" > /sys/kernel/debug/dsi_ss_ea8074_notch_fhd_cmd_display/ulps_enable

#Configure Thermal Profile
echo 10 > /sys/class/thermal/thermal_message/sconfig

}

setSimpleConfig &
