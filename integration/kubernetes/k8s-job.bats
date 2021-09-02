#!/usr/bin/env bats
#
# Copyright (c) 2019 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

set -x
load "${BATS_TEST_DIRNAME}/../../.ci/lib.sh"
load "${BATS_TEST_DIRNAME}/tests_common.sh"
issue="https://github.com/kata-containers/tests/issues/1746"

setup() {
	skip "test not working see: ${issue}"
	export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
	get_pod_config_dir
}

@test "Run a job to completion" {
	skip "test not working see: ${issue}"
	job_name="job-pi-test"

	# Create job
	kubectl apply -f "${pod_config_dir}/job.yaml"

	# Verify job
	kubectl describe jobs/"$job_name" | grep "SuccessfulCreate"

	# List pods that belong to the job
	pod_name=$(kubectl get pods --selector=job-name=$job_name --output=jsonpath='{.items[*].metadata.name}')

	# Verify that the job is completed
	cmd="kubectl get pods -o jsonpath='{.items[*].status.phase}' | grep Succeeded"
	waitForProcess "$wait_time" "$sleep_time" "$cmd"

	# Verify the output of the pod
	pi_number="3.14"
	kubectl logs "$pod_name" | grep "$pi_number"
}

teardown() {
	skip "test not working see: ${issue}"
	kubectl delete pod "$pod_name"
	# Verify that pod is not running
	run kubectl get pods
	echo "$output"
	[[ "$output" =~ "No resources found" ]]


	kubectl delete jobs/"$job_name"
	# Verify that the job is not running
	run kubectl get jobs
	echo "$output"
	[[ "$output" =~ "No resources found" ]]
}
