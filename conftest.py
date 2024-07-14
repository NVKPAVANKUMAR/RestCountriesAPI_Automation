import os.path
import shutil
import sys
from datetime import datetime
import os
import pytest

import env

sys.stdout = sys.stderr
server = None
test_name = ""
test_suite_name = None
t_array = []
t1 = None
current_file = ""
outcome = None

from helpers.logger import Logger

# Get logger instance for consolidated logs
logger = Logger().getLogger()


@pytest.fixture(autouse=True, scope='session')
def clean_reports():
    """
    Clean up the old reports before the test session starts.

    This fixture runs automatically before any tests are executed. It ensures that old Allure report
    directories are removed and a new reports directory is created.
    """

    allure_results_dir = "allure-results"
    if os.path.exists(allure_results_dir):
        shutil.rmtree(allure_results_dir)
    os.makedirs(allure_results_dir)

    report_dir = "allure-reports"
    if os.path.exists(report_dir):
        shutil.rmtree(report_dir)
    os.makedirs(report_dir)


# Update logging plugin to store logs from individual tests
@pytest.hookimpl
def pytest_runtest_setup(item):
    logging_plugin = item.config.pluginmanager.get_plugin("logging-plugin")
    timestamp = datetime.strftime(datetime.now(), '%Y-%m-%d')
    timestamp_test = "_" + str(datetime.strftime(datetime.now(), '%Y-%m-%d_%H-%M-%S'))
    logging_plugin.set_log_path(
        os.path.join('test_results/test_logs', timestamp, f'{item.name}' + timestamp_test + '.log'))


# Get filename from running test
def get_test_file_name():
    return os.getenv('PYTEST_CURRENT_TEST').split("::")[0].split("/")[-1].split(".py")[0]


# Fixture to run after each test function
@pytest.fixture(scope="function", autouse=True)
def execute_teardown(request):
    request.addfinalizer(tear_down)


def tear_down():
    logger.info(f"===============================================")


# Fixture to run before each test function
@pytest.fixture(scope="function", autouse=True)
def on_start():
    test_case_name = str(os.getenv('PYTEST_CURRENT_TEST').split("::")[1].split(" ")[0])
    logger.info(f"==========Test Case Execution started for test : '{test_case_name}'")


# Support for command line arguments
# def pytest_addoption(parser):
#     parser.addoption("--api_base_url", default="https://restcountries.com")
#     parser.addoption("--api_version", default="v3.1")

# Add Environment variable in global scope
def pytest_configure():
    env.load_config_variables()


# Update title of html report
def pytest_html_report_title(report):
    report.title = "API Automation Test Run Summary"


@pytest.hookimpl(tryfirst=True)
def pytest_sessionfinish(session, exitstatus):
    """
    Generate the Allure report at the end of the test session.

    This function is called after all tests have been executed. It generates the Allure report
    and saves it in a directory named with the current date. Optionally, it can serve the report
    automatically.

    Args:
        session: The pytest session object.
        exitstatus: The exit status of the pytest session.
    """
    timestamp = datetime.now().strftime('%Y-%m-%d')
    report_dir = f"allure-reports/allure_report_{timestamp}"
    logger.info(f"Generating Allure report on directory: {report_dir}")
    if not os.path.exists(report_dir):
        os.makedirs(report_dir)
    os.system(f"allure generate allure-results --clean -o {report_dir}")
    # Uncomment the next line if you want to open the report automatically
    os.system(f"allure open {report_dir}")
