package com.pixl.medchoice
import retrofit2.Call
import retrofit2.http.*


interface ApiInterface {

    @POST("location-tracking") // Endpoint path relative to base URL
    fun sendLocation(
        @Header("Authorization") bearerToken: String,
        @Body locationRequest: LocationReq
    ): Call<submitresponse>

}
