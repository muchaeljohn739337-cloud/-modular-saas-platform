"""
Main evaluation script for Trust & Trustpilot System

This script runs all evaluations and generates comprehensive reports.
"""

import os
import json
from datetime import datetime
from azure.ai.evaluation import evaluate

# Import custom evaluators
from evaluators import (
    TrustScoreEvaluator,
    InvitationEligibilityEvaluator,
    APICompletenessEvaluator,
    DataTypeEvaluator,
    ResponseTimeEvaluator
)


def ensure_directories():
    """Create necessary directories if they don't exist"""
    os.makedirs("evaluation/data", exist_ok=True)
    os.makedirs("evaluation/results", exist_ok=True)
    print("✓ Directories created")


def run_trust_score_evaluation():
    """Evaluate trust score calculation accuracy"""
    print("\n=== Running Trust Score Evaluation ===")
    
    trust_score_eval = TrustScoreEvaluator()
    
    try:
        result = evaluate(
            data="data/trust_score_tests.jsonl",
            evaluators={
                "trust_score": trust_score_eval
            },
            evaluator_config={
                "trust_score": {
                    "column_mapping": {
                        "ssl_valid": "${data.ssl_valid}",
                        "domain_age_months": "${data.domain_age_months}",
                        "trustpilot_rating": "${data.trustpilot_rating}",
                        "social_presence": "${data.social_presence}",
                        "expected_score": "${data.expected_score}"
                    }
                }
            },
            output_path="evaluation/results/trust_score_results.json"
        )
        
        accuracy = result["metrics"].get("trust_score.trust_score_accuracy", 0)
        print(f"✓ Trust Score Accuracy: {accuracy:.2%}")
        return result
    except FileNotFoundError:
        print("⚠ Test data file not found: evaluation/data/trust_score_tests.jsonl")
        return None
    except Exception as e:
        print(f"✗ Error: {e}")
        return None


def run_invitation_evaluation():
    """Evaluate invitation eligibility logic"""
    print("\n=== Running Invitation Eligibility Evaluation ===")
    
    invitation_eval = InvitationEligibilityEvaluator()
    
    try:
        result = evaluate(
            data="data/invitation_tests.jsonl",
            evaluators={
                "invitation": invitation_eval
            },
            evaluator_config={
                "invitation": {
                    "column_mapping": {
                        "amount": "${data.amount}",
                        "status": "${data.status}",
                        "days_since_transaction": "${data.days_since_transaction}",
                        "user_email": "${data.user_email}",
                        "already_invited": "${data.already_invited}",
                        "expected_eligible": "${data.expected_eligible}"
                    }
                }
            },
            output_path="evaluation/results/invitation_results.json"
        )
        
        accuracy = result["metrics"].get("invitation.invitation_logic_correct", 0)
        print(f"✓ Invitation Logic Accuracy: {accuracy:.2%}")
        return result
    except FileNotFoundError:
        print("⚠ Test data file not found: evaluation/data/invitation_tests.jsonl")
        return None
    except Exception as e:
        print(f"✗ Error: {e}")
        return None


def run_api_evaluation():
    """Evaluate API response quality"""
    print("\n=== Running API Response Evaluation ===")
    
    api_completeness_eval = APICompletenessEvaluator()
    data_type_eval = DataTypeEvaluator()
    response_time_eval = ResponseTimeEvaluator(target_ms=1000)
    
    try:
        result = evaluate(
            data="data/api_tests.jsonl",
            evaluators={
                "api_completeness": api_completeness_eval,
                "data_types": data_type_eval,
                "response_time": response_time_eval
            },
            evaluator_config={
                "api_completeness": {
                    "column_mapping": {
                        "response_data": "${data.response_data}",
                        "expected_fields": "${data.expected_fields}"
                    }
                },
                "data_types": {
                    "column_mapping": {
                        "response_data": "${data.response_data}"
                    }
                },
                "response_time": {
                    "column_mapping": {
                        "response_time_ms": "${data.response_time_ms}"
                    }
                }
            },
            output_path="evaluation/results/api_results.json"
        )
        
        completeness = result["metrics"].get("api_completeness.api_completeness", 0)
        type_accuracy = result["metrics"].get("data_types.data_type_accuracy", 0)
        response_score = result["metrics"].get("response_time.response_time_score", 0)
        
        print(f"✓ API Completeness: {completeness:.2%}")
        print(f"✓ Data Type Accuracy: {type_accuracy:.2%}")
        print(f"✓ Response Time Score: {response_score:.2%}")
        return result
    except FileNotFoundError:
        print("⚠ Test data file not found: evaluation/data/api_tests.jsonl")
        return None
    except Exception as e:
        print(f"✗ Error: {e}")
        return None


def generate_summary_report(results):
    """Generate a summary report from all evaluation results"""
    print("\n=== Generating Summary Report ===")
    
    summary = {
        "timestamp": datetime.now().isoformat(),
        "evaluations": {},
        "overall_status": "UNKNOWN"
    }
    
    # Extract metrics from results
    if results["trust_score"]:
        summary["evaluations"]["trust_score"] = {
            "accuracy": results["trust_score"]["metrics"].get("trust_score.trust_score_accuracy", 0),
            "status": "PASS" if results["trust_score"]["metrics"].get("trust_score.trust_score_accuracy", 0) >= 0.95 else "FAIL"
        }
    
    if results["invitation"]:
        summary["evaluations"]["invitation"] = {
            "accuracy": results["invitation"]["metrics"].get("invitation.invitation_logic_correct", 0),
            "status": "PASS" if results["invitation"]["metrics"].get("invitation.invitation_logic_correct", 0) >= 0.98 else "FAIL"
        }
    
    if results["api"]:
        api_metrics = results["api"]["metrics"]
        summary["evaluations"]["api"] = {
            "completeness": api_metrics.get("api_completeness.api_completeness", 0),
            "type_accuracy": api_metrics.get("data_types.data_type_accuracy", 0),
            "response_time": api_metrics.get("response_time.response_time_score", 0),
            "status": "PASS" if (
                api_metrics.get("api_completeness.api_completeness", 0) >= 0.95 and
                api_metrics.get("data_types.data_type_accuracy", 0) == 1.0 and
                api_metrics.get("response_time.response_time_score", 0) >= 0.8
            ) else "FAIL"
        }
    
    # Determine overall status
    all_pass = all(
        eval_result.get("status") == "PASS" 
        for eval_result in summary["evaluations"].values()
    )
    summary["overall_status"] = "PASS" if all_pass else "FAIL"
    
    # Save summary
    summary_path = "evaluation/results/summary.json"
    with open(summary_path, "w") as f:
        json.dump(summary, f, indent=2)
    
    print(f"✓ Summary report saved to {summary_path}")
    
    # Print summary
    print("\n" + "="*60)
    print("EVALUATION SUMMARY")
    print("="*60)
    
    for eval_name, eval_data in summary["evaluations"].items():
        status_icon = "✅" if eval_data["status"] == "PASS" else "❌"
        print(f"\n{status_icon} {eval_name.upper()}: {eval_data['status']}")
        for metric, value in eval_data.items():
            if metric != "status":
                if isinstance(value, float):
                    print(f"   - {metric}: {value:.2%}")
                else:
                    print(f"   - {metric}: {value}")
    
    print(f"\n{'='*60}")
    print(f"OVERALL STATUS: {summary['overall_status']}")
    print("="*60)
    
    return summary


def main():
    """Main execution function"""
    print("🚀 Starting Trust & Trustpilot System Evaluation")
    print("="*60)
    
    # Ensure directories exist
    ensure_directories()
    
    # Run all evaluations
    results = {
        "trust_score": run_trust_score_evaluation(),
        "invitation": run_invitation_evaluation(),
        "api": run_api_evaluation()
    }
    
    # Generate summary report
    if any(results.values()):
        summary = generate_summary_report(results)
        
        # Exit with appropriate code
        exit_code = 0 if summary["overall_status"] == "PASS" else 1
        print(f"\n{'✅ All evaluations passed!' if exit_code == 0 else '❌ Some evaluations failed.'}")
        return exit_code
    else:
        print("\n❌ No evaluations could be run. Check test data files.")
        return 1


if __name__ == "__main__":
    exit_code = main()
    exit(exit_code)
