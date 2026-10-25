"use server";

import { cookies, headers } from "next/headers";
import { redirect } from "next/navigation";

import {
  ORG_COOKIE,
  SESSION_COOKIE,
  confirmSignIn,
  requestSignIn,
  resolveSession,
  signOut,
} from "@/server/session";

function cookieOptions() {
  return {
    httpOnly: true,
    sameSite: "lax" as const,
    path: "/",
    secure: process.env.NODE_ENV === "production",
    maxAge: 60 * 60 * 24 * 14,
  };
}

function requestNotes() {
  const headerList = headers();
  const forwarded = headerList.get("x-forwarded-for");
  return {
    ipAddress: forwarded?.split(",")[0]?.trim() || headerList.get("x-real-ip"),
    userAgent: headerList.get("user-agent"),
  };
}

export async function startSignIn(formData: FormData) {
  const email = String(formData.get("email") ?? "");
  let token = "";
  try {
    token = (await requestSignIn(email)).token;
  } catch (error) {
    const message = error instanceof Error ? error.message : "Sign-in failed";
    redirect(`/sign-in?error=${encodeURIComponent(message)}`);
  }
  if (process.env.AUTH_EXPOSE_SIGNIN_TOKEN === "true") {
    redirect(`/sign-in?email=${encodeURIComponent(email)}&token=${encodeURIComponent(token)}`);
  }
  redirect(`/sign-in?email=${encodeURIComponent(email)}&sent=1`);
}

export async function finishSignIn(formData: FormData) {
  const email = String(formData.get("email") ?? "");
  const token = String(formData.get("token") ?? "");
  try {
    const notes = requestNotes();
    const signedIn = await confirmSignIn({
      email,
      token,
      ipAddress: notes.ipAddress,
      userAgent: notes.userAgent,
    });
    const session = await resolveSession(signedIn.sessionToken);
    cookies().set(SESSION_COOKIE, signedIn.sessionToken, cookieOptions());
    const organizationId = session?.memberships[0]?.organizationId;
    if (organizationId) {
      cookies().set(ORG_COOKIE, organizationId, cookieOptions());
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : "Sign-in failed";
    redirect(`/sign-in?email=${encodeURIComponent(email)}&error=${encodeURIComponent(message)}`);
  }
  redirect("/");
}

export async function endSignIn() {
  const token = cookies().get(SESSION_COOKIE)?.value;
  if (token) await signOut(token);
  cookies().delete(SESSION_COOKIE);
  cookies().delete(ORG_COOKIE);
  redirect("/");
}
