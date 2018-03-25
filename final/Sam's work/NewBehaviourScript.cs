using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour {

    public float x = 0f;
    public float firstPosition = 800f;
    public float SecondPosition = 1550f;
    public float counter = 0f;
	// Use this for initialization
	void Start () {
		
	}

    // Update is called once per frame
    void Update() {
        counter++;

        if (counter == 141 && x == 0)
        {
            counter = 800;
            x = 1f;
            transform.position = new Vector3(2, 0, 2);
        }

        if (counter == firstPosition) {
            transform.position = new Vector3(2, 0, 2);
        }

        if (counter >= SecondPosition) {
            transform.position = new Vector3(0, 0, 0);
            counter = 0;
        }
   
    }
}
