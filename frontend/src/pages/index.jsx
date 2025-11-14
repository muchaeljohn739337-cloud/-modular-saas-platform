import Layout from "../components/Layout";

export default function Home() {
  return (
    <Layout>
      <p>Welcome to Advvancia. Use the links above to log in or sign up.</p>
      <p>
        <a href="/login">Login</a> · <a href="/signup">Sign up</a>
      </p>
    </Layout>
  );
}
